USE equipcheck;

DELIMITER $$

-- equipamento
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
          R CHAR_LENGTH(TRIM(NEW.justificativa_alteracao)) < 10
          R (NEW.justificativa_alteracao <=> OLD.justificativa_alteracao) THEN
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
        irmware_novo, software_novo, responsavel, justificativa)
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

-- inspecao
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
          R CHAR_LENGTH(TRIM(NEW.responsavel_alteracao)) = 0
          R NEW.justificativa_alteracao IS NULL
          R CHAR_LENGTH(TRIM(NEW.justificativa_alteracao)) < 10
          R (NEW.justificativa_alteracao <=> OLD.justificativa_alteracao) THEN
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
          provada_anterior, aprovada_nova, observacao_nova,
          esponsavel, justificativa)
    VALUES
        (NEW.id_inspecao, OLD.medicao, NEW.medicao,
          LD.aprovada, NEW.aprovada, NEW.observacao,
          EW.responsavel_alteracao, NEW.justificativa_alteracao);

    -- O status do equipamento só é reavaliado se esta for a inspeção mais recente
    IF NEW.id_inspecao = (SELECT MAX(i.id_inspecao)
          ROM inspecao i
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

-- tabelas de histórico: somente inserção
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
          .versao_firmware,
          .versao_software,
          .status       AS status_atual,
          .medicao         AS ultima_medicao,
          .classificacao     AS ultima_classificacao,
          .aprovada          AS ultima_aprovada,
          .responsavel      S ultimo_responsavel,
          .data_hora       AS ultima_inspecao
FROM equipamento e
LEFT JOIN inspecao i
  ON i.id_inspecao = (
          ELECT i2.id_inspecao
          ROM inspecao i2
          HERE i2.id_equipamento = e.id_equipamento
          RDER BY i2.data_hora DESC, i2.id_inspecao DESC
          IMIT 1
      );
