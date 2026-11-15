# Dicionário de Dados — EquipCheck Mini

Descrição de cada coluna do banco `equipcheck`.
## `equipamento`

| Coluna | Descrição | Regra |
|---|---|---|
| `id_equipamento` | Identificador único do equipamento | Formato `EQP-NNN` (3 ou mais dígitos) |
| `versao_firmware` | Versão atual do firmware | Obrigatória, não vazia |
| `versao_software` | Versão atual do aplicativo de configuração | Obrigatória, não vazia |
| `status` | Condição de liberação atual | `Apto` ou `Bloqueado`; nasce `Bloqueado`; mantido por triggers (RF04) |
| `cadastrado_por` | Quem cadastrou o equipamento | Obrigatório, não vazio |
| `cadastrado_em` | Data e hora do cadastro | Preenchida automaticamente |
| `responsavel_alteracao` | Responsável pela última alteração de versão | Obrigatório ao alterar versões (RF05) |
| `justificativa_alteracao` | Justificativa da última alteração de versão | Mínimo de 10 caracteres e diferente da anterior (RF05) |

## `inspecao`

| Coluna | Descrição | Regra |
|---|---|---|
| `id_inspecao` | Identificador da inspeção | Gerado automaticamente |
| `id_equipamento` | Equipamento inspecionado | Deve existir em `equipamento` |
| `medicao` | Medição numérica da inspeção | Decimal com 2 casas; faixa válida de 10.00 a 20.00 (RF02) |
| `classificacao` | Resultado da medição | Calculada: `Apto` de 10.00 a 20.00 (inclusive), senão `Bloqueado` (RF03) |
| `aprovada` | Indica se a inspeção foi aprovada | 0 (não) ou 1 (sim); só uma inspeção aprovada e dentro da faixa libera o equipamento (RF04) |
| `responsavel` | Quem realizou a inspeção | Obrigatório; não pode ser alterado |
| `observacao` | Comentário livre sobre a inspeção | Opcional |
| `versao_firmware` | Firmware do equipamento na data da inspeção | Copiada do equipamento por trigger; não pode ser alterada (RF06) |
| `versao_software` | Software do equipamento na data da inspeção | Copiada do equipamento por trigger; não pode ser alterada (RF06) |
| `data_hora` | Data e hora da inspeção | Preenchida automaticamente; não pode ser alterada |
| `responsavel_alteracao` | Responsável pela última correção | Obrigatório ao corrigir medição, aprovação ou observação (RF05) |
| `justificativa_alteracao` | Justificativa da última correção | Mínimo de 10 caracteres e diferente da anterior (RF05) |

## `historico_equipamento`

| Coluna | Descrição |
|---|---|
| `id_historico` | Identificador do registro de histórico |
| `id_equipamento` | Equipamento alterado |
| `firmware_anterior`, `software_anterior` | Versões antes da mudança (nulas no cadastro inicial) |
| `firmware_novo`, `software_novo` | Versões depois da mudança |
| `responsavel` | Quem fez a mudança |
| `justificativa` | Motivo da mudança (no cadastro inicial: "Cadastro inicial do equipamento") |
| `data_hora` | Data e hora da mudança |

## `historico_inspecao`

| Coluna | Descrição |
|---|---|
| `id_historico` | Identificador do registro de histórico |
| `id_inspecao` | Inspeção corrigida |
| `medicao_anterior`, `medicao_nova` | Medição antes e depois da correção |
| `aprovada_anterior`, `aprovada_nova` | Aprovação antes e depois da correção |
| `observacao_nova` | Observação após a correção |
| `responsavel` | Quem fez a correção |
| `justificativa` | Motivo da correção |
| `data_hora` | Data e hora da correção |

## Objetos do banco

| Objeto | Tipo | Descrição |
|---|---|---|
| `v_status_atual_equipamento` | View | Status atual de cada equipamento com os dados da última inspeção |
| `trg_*` | Triggers | Regras RF04, RF05 e RF06; lista completa em `modelo-relacional.md` |
