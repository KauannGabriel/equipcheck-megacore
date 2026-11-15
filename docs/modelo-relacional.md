# Modelo Relacional (3FN) — EquipCheck Mini

## Tabelas

### `equipamento`

| Coluna | Tipo | Restrições |
|---|---|---|
| `id_equipamento` | `VARCHAR(20)` | **PK**, `CHECK` formato `EQP-NNN` |
| `versao_firmware` | `VARCHAR(30)` | `NOT NULL`, `CHECK` não vazio |
| `versao_software` | `VARCHAR(30)` | `NOT NULL`, `CHECK` não vazio |
| `status` | `ENUM('Apto','Bloqueado')` | `NOT NULL`, padrão `'Bloqueado'` |
| `cadastrado_por` | `VARCHAR(100)` | `NOT NULL`, `CHECK` não vazio |
| `cadastrado_em` | `TIMESTAMP` | `NOT NULL`, padrão data e hora atual |
| `responsavel_alteracao` | `VARCHAR(100)` | `NULL` (parâmetro da operação de alteração) |
| `justificativa_alteracao` | `TEXT` | `NULL` (parâmetro da operação de alteração) |

### `inspecao`

| Coluna | Tipo | Restrições |
|---|---|---|
| `id_inspecao` | `BIGINT UNSIGNED` | **PK**, `AUTO_INCREMENT` |
| `id_equipamento` | `VARCHAR(20)` | **FK** para `equipamento`, `NOT NULL`, `RESTRICT` |
| `medicao` | `DECIMAL(8,2)` | `NOT NULL` |
| `classificacao` | `ENUM('Apto','Bloqueado')` | coluna gerada `VIRTUAL` a partir de `medicao` |
| `aprovada` | `TINYINT` | `NOT NULL`, padrão 0 |
| `responsavel` | `VARCHAR(100)` | `NOT NULL`, `CHECK` não vazio |
| `observacao` | `TEXT` | `NULL` |
| `versao_firmware` | `VARCHAR(30)` | `NOT NULL`, preenchida por trigger, `CHECK` não vazio |
| `versao_software` | `VARCHAR(30)` | `NOT NULL`, preenchida por trigger, `CHECK` não vazio |
| `data_hora` | `TIMESTAMP` | `NOT NULL`, padrão data e hora atual |
| `responsavel_alteracao` | `VARCHAR(100)` | `NULL` (parâmetro da operação de alteração) |
| `justificativa_alteracao` | `TEXT` | `NULL` (parâmetro da operação de alteração) |

### `historico_equipamento`

| Coluna | Tipo | Restrições |
|---|---|---|
| `id_historico` | `BIGINT UNSIGNED` | **PK**, `AUTO_INCREMENT` |
| `id_equipamento` | `VARCHAR(20)` | **FK** para `equipamento`, `NOT NULL`, `RESTRICT` |
| `firmware_anterior`, `software_anterior` | `VARCHAR(30)` | `NULL` (nulos no cadastro inicial) |
| `firmware_novo`, `software_novo` | `VARCHAR(30)` | `NOT NULL` |
| `responsavel` | `VARCHAR(100)` | `NOT NULL` |
| `justificativa` | `TEXT` | `NOT NULL` |
| `data_hora` | `TIMESTAMP` | `NOT NULL`, padrão data e hora atual |

### `historico_inspecao`

| Coluna | Tipo | Restrições |
|---|---|---|
| `id_historico` | `BIGINT UNSIGNED` | **PK**, `AUTO_INCREMENT` |
| `id_inspecao` | `BIGINT UNSIGNED` | **FK** para `inspecao`, `NOT NULL`, `RESTRICT` |
| `medicao_anterior`, `medicao_nova` | `DECIMAL(8,2)` | `NOT NULL` |
| `aprovada_anterior`, `aprovada_nova` | `TINYINT` | `NOT NULL` |
| `observacao_nova` | `TEXT` | `NULL` |
| `responsavel` | `VARCHAR(100)` | `NOT NULL` |
| `justificativa` | `TEXT` | `NOT NULL` |
| `data_hora` | `TIMESTAMP` | `NOT NULL`, padrão data e hora atual |

## Chaves estrangeiras

| Tabela filha | Coluna | Tabela pai | Ação em `UPDATE` / `DELETE` |
|---|---|---|---|
| `inspecao` | `id_equipamento` | `equipamento` | `RESTRICT` / `RESTRICT` |
| `historico_equipamento` | `id_equipamento` | `equipamento` | `RESTRICT` / `RESTRICT` |
| `historico_inspecao` | `id_inspecao` | `inspecao` | `RESTRICT` / `RESTRICT` |

## Objetos programáveis

| Objeto | Função | Requisito |
|---|---|---|
| `trg_equip_ai` | Registra o cadastro inicial em `historico_equipamento` | RF06 |
| `trg_equip_bu` | Exige responsável e justificativa para alterar versão | RF05 |
| `trg_equip_au` | Grava a mudança de versão em `historico_equipamento` | RF06 |
| `trg_insp_bi` | Copia as versões vigentes do equipamento para a inspeção | RF06 |
| `trg_insp_ai` | Atualiza o status do equipamento após uma inspeção | RF03, RF04 |
| `trg_insp_bu` | Limita as colunas alteráveis e exige responsável e justificativa | RF05 |
| `trg_insp_au` | Grava a correção em `historico_inspecao` e reavalia o status | RF04, RF06 |
| `trg_equip_bd`, `trg_insp_bd` | Bloqueiam `DELETE` em `equipamento` e `inspecao` | RF06 |
| `trg_hist_equip_bu/bd`, `trg_hist_insp_bu/bd` | Tornam os históricos somente inserção | RF06 |
| `v_status_atual_equipamento` (view) | Status atual de cada equipamento com a última inspeção | RF03, RF04 |

## Ordem de execução dos scripts

1. `sql/01-create-database.sql`
2. `sql/02-create-tables.sql`
3. `sql/03-triggers-views.sql`
4. `sql/04-inserts.sql`
5. `sql/05-queries.sql`
