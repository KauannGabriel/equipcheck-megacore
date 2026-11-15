USE equipcheck;

-- RF01: equipamento com identificador único e versões obrigatórias
-- RF04: status atual (só volta a Apto após nova inspeção aprovada)
-- RF05: alteração de versão exige responsável + justificativa
CREATE TABLE equipamento (
  id_equipamento          VARCHAR(20)  NOT NULL,
  versao_firmware         VARCHAR(30)  NOT NULL,
  versao_software         VARCHAR(30)  NOT NULL,
  -- Conservador: equipamento novo nasce Bloqueado até a primeira inspeção aprovada
  status                  ENUM('Apto','Bloqueado') NOT NULL DEFAULT 'Bloqueado',
  cadastrado_por          VARCHAR(100) NOT NULL,
  cadastrado_em           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  -- Parâmetros da operação: preenchidos no próprio UPDATE que altera as versões (RF05)
  responsavel_alteracao   VARCHAR(100) NULL,
  justificativa_alteracao TEXT         NULL,
  CONSTRAINT pk_equipamento PRIMARY KEY (id_equipamento),
  CONSTRAINT ck_equip_id CHECK (id_equipamento REGEXP '^EQP-[0-9]{3,}$'),
  CONSTRAINT ck_equip_firmware CHECK (CHAR_LENGTH(TRIM(versao_firmware)) > 0),
  CONSTRAINT ck_equip_software CHECK (CHAR_LENGTH(TRIM(versao_software)) > 0),
  CONSTRAINT ck_equip_cadastrado_por CHECK (CHAR_LENGTH(TRIM(cadastrado_por)) > 0)
) ENGINE=InnoDB;

-- RF02: medição numérica | RF03: classificação pela faixa 10 a 20 (inclusive)
-- RF06: versões de firmware e software associadas a cada registro
CREATE TABLE inspecao (
  id_inspecao             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_equipamento          VARCHAR(20)     NOT NULL,
  medicao                 DECIMAL(8,2)    NOT NULL,
  -- RF03: atributo derivado, calculado na leitura (VIRTUAL = não ocupa armazenamento)
  classificacao           ENUM('Apto','Bloqueado')
                          GENERATED ALWAYS AS (
                            IF(medicao BETWEEN 10.00 AND 20.00, 'Apto', 'Bloqueado')
                          ) VIRTUAL,
  -- RF04: só uma inspeção aprovada devolve o equipamento a Apto
  aprovada                TINYINT         NOT NULL DEFAULT 0,
  responsavel             VARCHAR(100)    NOT NULL,
  observacao              TEXT            NULL,

  versao_firmware         VARCHAR(30)     NOT NULL DEFAULT '',
  versao_software         VARCHAR(30)     NOT NULL DEFAULT '',
  data_hora               TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  -- Parâmetros da operação (RF05): preenchidos no UPDATE que altera medição,
  -- aprovação ou observação
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

-- RF06: histórico de mudanças (somente inserção)
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
  aprovada_anterior TINYINT         NOT NULL,
  aprovada_nova     TINYINT         NOT NULL,
  observacao_nova   TEXT            NULL,
  responsavel       VARCHAR(100)    NOT NULL,
  justificativa     TEXT            NOT NULL,
  data_hora         TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_hist_insp PRIMARY KEY (id_historico),
  CONSTRAINT fk_hist_insp FOREIGN KEY (id_inspecao)
    REFERENCES inspecao (id_inspecao)
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  INDEX idx_hist_insp (id_inspecao, data_hora)
) ENGINE=InnoDB;
