# Levantamento de Requisitos — EquipCheck Mini

## 1. Técnica utilizada

**Análise de documentos.** Os requisitos partem do enunciado do Cenário 5 MegaCore Labs (relato do cotidiano da empresa, indicadores e requisitos do aplicativo EquipCheck Mini). Não foram realizadas entrevistas nem questionários, pois a empresa é fictícia. Os requisitos não funcionais e as regras de negócio derivadas foram propostos pela equipe e estão indicados como tal.

## 2. Requisitos funcionais

Os RF01 a RF06 vêm do enunciado.

| ID | Descrição | Prioridade |
|---|---|---|
| RF01 | Cadastrar equipamento com identificador único e versões de firmware e software obrigatórias. | Essencial |
| RF02 | Registrar uma medição numérica em inspeção, usando a faixa didática de 10 a 20, incluindo os extremos. | Essencial |
| RF03 | Classificar como Bloqueado se a medição estiver fora da faixa; dentro dela, classificar como Apto. | Essencial |
| RF04 | Permitir que um equipamento Bloqueado volte a Apto somente após nova inspeção aprovada. | Essencial |
| RF05 | Exigir responsável e justificativa para alteração de versão ou de dados da inspeção. | Essencial |
| RF06 | Preservar o histórico de inspeções e mudanças, incluindo as versões de firmware e software associadas a cada registro. | Essencial |

### Critérios de aceitação

| ID | Critério de aceitação |
|---|---|
| RF01 | Cadastro com ID repetido é rejeitado. Cadastro sem versão de firmware ou de software é rejeitado. O ID segue o formato `EQP-001`. |
| RF02 | A medição é gravada como número decimal. Valor não numérico é rejeitado. |
| RF03 | 10.00 e 20.00 resultam em Apto. 9.99 e 20.01 resultam em Bloqueado. A classificação não é informada pelo usuário. |
| RF04 | Após uma inspeção fora da faixa, o equipamento fica Bloqueado. Uma nova inspeção dentro da faixa sem aprovação não o libera. Uma nova inspeção dentro da faixa e aprovada o devolve a Apto. |
| RF05 | Alterar versão ou dados de uma inspeção sem responsável ou sem justificativa é rejeitado. A justificativa tem no mínimo 10 caracteres e é diferente da anterior. |
| RF06 | Cada inspeção guarda as versões vigentes. Cada mudança de versão ou de dados de inspeção gera um registro de histórico com valor anterior, valor novo, responsável, justificativa e data e hora. Registros de histórico não podem ser alterados nem excluídos. |

## 3. Requisitos não funcionais (proposta da equipe)

| ID | Categoria | Descrição | Prioridade |
|---|---|---|---|
| RNF01 | Integridade | O banco garante integridade referencial (chaves estrangeiras) e as regras de negócio por restrições `CHECK` e triggers. | Essencial |
| RNF02 | Rastreabilidade | Todo registro de histórico possui data e hora (`TIMESTAMP`) e responsável. | Essencial |
| RNF03 | Normalização | O modelo relacional está normalizado até a 3FN, com justificativa das redundâncias controladas. | Essencial |
| RNF04 | Segurança | Exclusão de equipamentos, inspeções e históricos é bloqueada no banco. | Essencial |
| RNF05 | Portabilidade | O banco é criado a partir de scripts SQL numerados, executados em ordem. | Essencial |
| RNF06 | Usabilidade | Mensagens de erro dos triggers são claras e indicam o que corrigir. | Desejável |
| RNF07 | Desempenho | Consultas por equipamento e data usam índices (`idx_inspecao_equip_data`, `idx_hist_equip`, `idx_hist_insp`). | Desejável |

## 4. Regras de negócio que impactam o modelo de dados

| ID | Regra |
|---|---|
| RN01 | O status do equipamento nunca é informado manualmente; é consequência das inspeções. |
| RN02 | A classificação da medição é Apto se estiver entre 10.00 e 20.00, inclusive, e Bloqueado caso contrário. |
| RN03 | Um equipamento Bloqueado só volta a Apto após uma nova inspeção dentro da faixa e aprovada. |
| RN04 | Toda alteração de versão ou de dados de inspeção exige responsável e justificativa. |
| RN05 | Equipamentos e inspeções não são excluídos. |
| RN06 | Em uma inspeção, somente medição, aprovação e observação podem ser corrigidas; equipamento, responsável original, data e versões são fixos. |
| RN07 | Cada inspeção guarda as versões de firmware e software que o equipamento tinha no momento do registro. |

## 5. Rastreabilidade requisito, risco e verificação

| Requisito | Risco relacionado | Onde é garantido no banco | Verificação (arquivo `sql/05-queries.sql`) |
|---|---|---|---|
| RF01 | Equipamento sem versão compromete a rastreabilidade | `PK`, `CHECK` de ID e versões não vazias | Testes de ID duplicado e fora do formato |
| RF02 | Medição inválida entra no histórico | `medicao DECIMAL(8,2) NOT NULL` | Consulta 2 |
| RF03 | Classificação errada libera equipamento fora da faixa | Coluna virtual `classificacao` | Consultas 2 e 5 (bordas 9.99, 10.00, 20.00) |
| RF04 | Equipamento bloqueado liberado sem nova inspeção aprovada | Triggers `trg_insp_ai` e `trg_insp_au` | Consultas 1, 3 e 11 |
| RF05 | Mudança sem responsável ou justificativa | Triggers `trg_equip_bu` e `trg_insp_bu` | Testes de alteração sem campos e com justificativa curta |
| RF06 | Impossibilidade de reconstruir a liberação | Tabelas de histórico, triggers de imutabilidade, versões em `inspecao` | Consultas 7, 9, 10 e 12 e testes de exclusão |

## 6. Pontos em aberto

- Quem pode aprovar uma inspeção: qualquer usuário ou um perfil específico?
- O estado inicial de um equipamento novo deve ser Bloqueado?
- A faixa de 10 a 20 pode variar por tipo de equipamento no futuro?
- Como identificar o responsável sem autenticação?
