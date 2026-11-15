-- EquipCheck Mini (MegaCore Labs) - Cenário 5 / Projeto A3
-- Requer MySQL 8.0.16+ (CHECK constraints são aplicadas a partir dessa versão)
-- Ambiente de desenvolvimento: para recriar, rode DROP DATABASE equipcheck; antes.

CREATE DATABASE IF NOT EXISTS equipcheck
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE equipcheck;

-- ---------------------------------------------------------------
-- RF01: equipamento com identificador único e versões obrigatórias
-- RF04: status atual (só volta a Apto após nova inspeção aprovada)
-- RF05: alteração de versão exige responsável + justificativa
-- ---------------------------------------------------------------
CREATE TABLE equipamento (
    id_equipamento          VARCHAR(20)  NOT NULL,
    versao_firmware         VARCHAR(30)  NOT NULL,
    versao_software         VARCHAR(30)  NOT NULL,
    -- Conservador: equipamento novo nasce Bloqueado até a primeira inspeção aprovada
    status                  ENUM('Apto','Bloqueado') NOT NULL DEFAULT 'Bloqueado',
    cadastrado_por          VARCHAR(100) NOT NULL,
    cadastrado_em           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Preenchidos no próprio UPDATE que altera as versões (RF05)
    responsavel_alteracao   VARCHAR(100) NULL,
    justificativa_alteracao TEXT         NULL,
    CONSTRAINT pk_equipamento PRIMARY KEY (id_equipamento),
    CONSTRAINT ck_equip_id CHECK (id_equipamento REGEXP '^EQP-[0-9]{3,}$'),
    CONSTRAINT ck_equip_firmware CHECK (CHAR_LENGTH(TRIM(versao_firmware)) > 0),
    CONSTRAINT ck_equip_software CHECK (CHAR_LENGTH(TRIM(versao_software)) > 0),
    CONSTRAINT ck_equip_cadastrado_por CHECK (CHAR_LENGTH(TRIM(cadastrado_por)) > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- RF02: medição numérica | RF03: classificação pela faixa 10 a 20 (inclusive)
-- RF06: versões de firmware e software associadas a cada registro
-- ---------------------------------------------------------------
CREATE TABLE inspecao (
    id_inspecao             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_equipamento          VARCHAR(20)     NOT NULL,
    medicao                 DECIMAL(8,2)    NOT NULL,
    -- RF03: derivada da medição, nunca informada manualmente
    classificacao           ENUM('Apto','Bloqueado')
                            GENERATED ALWAYS AS (
                            IF(medicao BETWEEN 10.00 AND 20.00, 'Apto', 'Bloqueado')
                            ) STORED,
    -- RF04: só uma inspeção aprovada devolve o equipamento a Apto
    aprovada                TINYINT(1)      NOT NULL DEFAULT 0,
    responsavel             VARCHAR(100)    NOT NULL,
    observacao              TEXT            NULL,
    -- Copiadas do equipamento no INSERT (trigger). DEFAULT '' evita erro de NOT NULL
    -- antes do trigger rodar; o CHECK abaixo garante que não fiquem vazias.
    versao_firmware         VARCHAR(30)     NOT NULL DEFAULT '',
    versao_software         VARCHAR(30)     NOT NULL DEFAULT '',
    data_hora               TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- RF05: preenchidos no UPDATE que altera medição, aprovação ou observação
    responsavel_alteracao   VARCHAR(100)    NULL,
    justificativa_alteracao TEXT            NULL,
    CONSTRAINT pk_inspecao PRIMARY KEY (id_inspecao),
    CONSTRAINT fk_inspecao_equip FOREIGN KEY (id_equipamento)
    REFERENCES equipamento (id_equipamento)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ck_insp_responsavel CHECK (CHAR_LENGTH(TRIM(responsavel)) > 0),
    CONSTRAINT ck_insp_versoes CHECK (CHAR_LENGTH(versao_firmware) > 0
                                    AND CHAR_LENGTH(versao_software) > 0),
    INDEX idx_inspecao_equip_data (id_equipamento, data_hora)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------
-- RF06: histórico de mudanças (somente inserção)
-- ---------------------------------------------------------------
CREATE TABLE historico_equipamento (
    id_historico      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_equipamento    VARCHAR(20)     NOT NULL,
    firmware_anterior VARCHAR(30)     NULL,
    software_anterior VARCHAR(30)     NULL,
    firmware_novo     VARCHAR(30)     NOT NULL,
    software_novo     VARCHAR(30)     NOT NULL,
    responsavel       VARCHAR(100)    NOT NULL,
    justificativa     TEXT            NOT NULL,
    data_hora         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_hist_equip PRIMARY KEY (id_historico),
    CONSTRAINT fk_hist_equip FOREIGN KEY (id_equipamento)
    REFERENCES equipamento (id_equipamento)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
    INDEX idx_hist_equip (id_equipamento, data_hora)
) ENGINE=InnoDB;

CREATE TABLE historico_inspecao (
    id_historico      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_inspecao       BIGINT UNSIGNED NOT NULL,
    medicao_anterior  DECIMAL(8,2)    NOT NULL,
    medicao_nova      DECIMAL(8,2)    NOT NULL,
    aprovada_anterior TINYINT(1)      NOT NULL,
    aprovada_nova     TINYINT(1)      NOT NULL,
    observacao_nova   TEXT            NULL,
    versao_firmware   VARCHAR(30)     NOT NULL,
    versao_software   VARCHAR(30)     NOT NULL,
    responsavel       VARCHAR(100)    NOT NULL,
    justificativa     TEXT            NOT NULL,
    data_hora         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_hist_insp PRIMARY KEY (id_historico),
    CONSTRAINT fk_hist_insp FOREIGN KEY (id_inspecao)
    REFERENCES inspecao (id_inspecao)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
    INDEX idx_hist_insp (id_inspecao, data_hora)
) ENGINE=InnoDB;

DELIMITER $$

-- ===============================================================
-- equipamento
-- ===============================================================
CREATE TRIGGER trg_equip_ai
AFTER INSERT ON equipamento
FOR EACH ROW
BEGIN
    INSERT INTO historico_equipamento
    (id_equipamento, firmware_anterior, software_anterior,
        firmware_novo, software_novo, responsavel, justificativa)
    VALUES
    (NEW.id_equipamento, NULL, NULL,
        NEW.versao_firmware, NEW.versao_software, NEW.cadastrado_por,
        'Cadastro inicial do equipamento');
END$$

CREATE TRIGGER trg_equip_bu
BEFORE UPDATE ON equipamento
FOR EACH ROW
BEGIN
    -- RF05: mudança de versão exige responsável e justificativa novos
    IF NOT (NEW.versao_firmware <=> OLD.versao_firmware)
        OR NOT (NEW.versao_software <=> OLD.versao_software) THEN
    IF NEW.responsavel_alteracao IS NULL
        OR CHAR_LENGTH(TRIM(NEW.responsavel_alteracao)) = 0
        OR NEW.justificativa_alteracao IS NULL
        OR CHAR_LENGTH(TRIM(NEW.justificativa_alteracao)) < 10
        OR (NEW.justificativa_alteracao <=> OLD.justificativa_alteracao) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alteração de versão exige responsavel_alteracao e justificativa_alteracao (mín. 10 caracteres, nova a cada alteração).';
    END IF;
    END IF;
END$$

CREATE TRIGGER trg_equip_au
AFTER UPDATE ON equipamento
FOR EACH ROW
BEGIN
    IF NOT (NEW.versao_firmware <=> OLD.versao_firmware)
        OR NOT (NEW.versao_software <=> OLD.versao_software) THEN
    INSERT INTO historico_equipamento
        (id_equipamento, firmware_anterior, software_anterior,
        firmware_novo, software_novo, responsavel, justificativa)
    VALUES
        (NEW.id_equipamento, OLD.versao_firmware, OLD.versao_software,
        NEW.versao_firmware, NEW.versao_software,
        NEW.responsavel_alteracao, NEW.justificativa_alteracao);
    END IF;
END$$

CREATE TRIGGER trg_equip_bd
BEFORE DELETE ON equipamento
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Equipamentos não podem ser excluídos (histórico preservado).';
END$$

-- ===============================================================
-- inspecao
-- ===============================================================
CREATE TRIGGER trg_insp_bi
BEFORE INSERT ON inspecao
FOR EACH ROW
BEGIN
    DECLARE v_fw VARCHAR(30);
    DECLARE v_sw VARCHAR(30);

    SELECT versao_firmware, versao_software
    INTO v_fw, v_sw
    FROM equipamento
    WHERE id_equipamento = NEW.id_equipamento;

    SET NEW.versao_firmware = COALESCE(v_fw, '');
    SET NEW.versao_software = COALESCE(v_sw, '');
END$$

CREATE TRIGGER trg_insp_ai
AFTER INSERT ON inspecao
FOR EACH ROW
BEGIN
    -- RF03/RF04: fora da faixa bloqueia; dentro da faixa só libera se aprovada
    IF NOT (NEW.medicao BETWEEN 10.00 AND 20.00) THEN
    UPDATE equipamento SET status = 'Bloqueado'
        WHERE id_equipamento = NEW.id_equipamento;
    ELSEIF NEW.aprovada = 1 THEN
    UPDATE equipamento SET status = 'Apto'
        WHERE id_equipamento = NEW.id_equipamento;
    END IF;
END$$

CREATE TRIGGER trg_insp_bu
BEFORE UPDATE ON inspecao
FOR EACH ROW
BEGIN
    -- Só medição, aprovação e observação podem ser corrigidas
    IF NOT (NEW.id_equipamento <=> OLD.id_equipamento)
        OR NOT (NEW.responsavel <=> OLD.responsavel)
        OR NOT (NEW.data_hora <=> OLD.data_hora)
        OR NOT (NEW.versao_firmware <=> OLD.versao_firmware)
        OR NOT (NEW.versao_software <=> OLD.versao_software) THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Somente medicao, aprovada e observacao podem ser alteradas em uma inspecao.';
    END IF;

    -- RF05: alteração de dados da inspeção exige responsável e justificativa novos
    IF NOT (NEW.medicao <=> OLD.medicao)
        OR NOT (NEW.aprovada <=> OLD.aprovada)
        OR NOT (NEW.observacao <=> OLD.observacao) THEN
    IF NEW.responsavel_alteracao IS NULL
        OR CHAR_LENGTH(TRIM(NEW.responsavel_alteracao)) = 0
        OR NEW.justificativa_alteracao IS NULL
        OR CHAR_LENGTH(TRIM(NEW.justificativa_alteracao)) < 10
        OR (NEW.justificativa_alteracao <=> OLD.justificativa_alteracao) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Alteração de inspeção exige responsavel_alteracao e justificativa_alteracao (mín. 10 caracteres, nova a cada alteração).';
    END IF;
    END IF;
END$$

CREATE TRIGGER trg_insp_au
AFTER UPDATE ON inspecao
FOR EACH ROW
BEGIN
    IF NOT (NEW.medicao <=> OLD.medicao)
        OR NOT (NEW.aprovada <=> OLD.aprovada)
        OR NOT (NEW.observacao <=> OLD.observacao) THEN

    INSERT INTO historico_inspecao
        (id_inspecao, medicao_anterior, medicao_nova,
        aprovada_anterior, aprovada_nova, observacao_nova,
        versao_firmware, versao_software, responsavel, justificativa)
    VALUES
        (NEW.id_inspecao, OLD.medicao, NEW.medicao,
        OLD.aprovada, NEW.aprovada, NEW.observacao,
        NEW.versao_firmware, NEW.versao_software,
        NEW.responsavel_alteracao, NEW.justificativa_alteracao);

    -- O status do equipamento só é reavaliado se esta for a inspeção mais recente
    IF NEW.id_inspecao = (SELECT MAX(i.id_inspecao)
                            FROM inspecao i
                            WHERE i.id_equipamento = NEW.id_equipamento) THEN
        IF NOT (NEW.medicao BETWEEN 10.00 AND 20.00) THEN
        UPDATE equipamento SET status = 'Bloqueado'
            WHERE id_equipamento = NEW.id_equipamento;
        ELSEIF NEW.aprovada = 1 THEN
        UPDATE equipamento SET status = 'Apto'
            WHERE id_equipamento = NEW.id_equipamento;
        END IF;
    END IF;
    END IF;
END$$

CREATE TRIGGER trg_insp_bd
BEFORE DELETE ON inspecao
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Inspeções não podem ser excluídas (histórico preservado).';
END$$

-- ===============================================================
-- tabelas de histórico: somente inserção
-- ===============================================================
CREATE TRIGGER trg_hist_equip_bu BEFORE UPDATE ON historico_equipamento
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'historico_equipamento é somente inserção.';
END$$

CREATE TRIGGER trg_hist_equip_bd BEFORE DELETE ON historico_equipamento
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'historico_equipamento é somente inserção.';
END$$

CREATE TRIGGER trg_hist_insp_bu BEFORE UPDATE ON historico_inspecao
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'historico_inspecao é somente inserção.';
END$$

CREATE TRIGGER trg_hist_insp_bd BEFORE DELETE ON historico_inspecao
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'historico_inspecao é somente inserção.';
END$$

DELIMITER ;

-- Situação atual de cada equipamento com a última inspeção registrada
CREATE OR REPLACE VIEW v_status_atual_equipamento AS
SELECT e.id_equipamento,
        e.versao_firmware,
        e.versao_software,
        e.status            AS status_atual,
        i.medicao           AS ultima_medicao,
        i.classificacao     AS ultima_classificacao,
        i.aprovada          AS ultima_aprovada,
        i.responsavel       AS ultimo_responsavel,
        i.data_hora         AS ultima_inspecao
FROM equipamento e
LEFT JOIN inspecao i
ON i.id_inspecao = (
        SELECT i2.id_inspecao
        FROM inspecao i2
        WHERE i2.id_equipamento = e.id_equipamento
        ORDER BY i2.data_hora DESC, i2.id_inspecao DESC
        LIMIT 1
    );

-- ---------------------------------------------------------------
-- Testes rápidos (descomente para validar)
-- ---------------------------------------------------------------
-- INSERT INTO equipamento (id_equipamento, versao_firmware, versao_software, cadastrado_por)
--   VALUES ('EQP-001', 'FW 2.1.0', 'SW 5.3.2', 'Maria Silva');
--
-- RF03: fora da faixa -> Bloqueado
-- INSERT INTO inspecao (id_equipamento, medicao, responsavel) VALUES ('EQP-001', 22.30, 'João Souza');
-- SELECT status FROM equipamento WHERE id_equipamento = 'EQP-001';   -- Bloqueado
--
-- RF04: Apto dentro da faixa mas sem aprovação -> continua Bloqueado
-- INSERT INTO inspecao (id_equipamento, medicao, responsavel) VALUES ('EQP-001', 15.00, 'João Souza');
-- RF04: nova inspeção aprovada -> volta a Apto
-- INSERT INTO inspecao (id_equipamento, medicao, aprovada, responsavel) VALUES ('EQP-001', 10.00, 1, 'João Souza');
--
-- RF05: alterar versão sem justificativa -> ERRO
-- UPDATE equipamento SET versao_firmware = 'FW 2.2.0' WHERE id_equipamento = 'EQP-001';
-- RF05: com responsável e justificativa -> OK e registrado em historico_equipamento
-- UPDATE equipamento SET versao_firmware = 'FW 2.2.0',
--   responsavel_alteracao = 'Ana Lima',
--   justificativa_alteracao = 'Correção de falha de comunicação com o aplicativo'
--  WHERE id_equipamento = 'EQP-001';
--
-- RF06: excluir -> ERRO
-- DELETE FROM inspecao WHERE id_inspecao = 1;
-- SELECT * FROM historico_equipamento; SELECT * FROM historico_inspecao;
