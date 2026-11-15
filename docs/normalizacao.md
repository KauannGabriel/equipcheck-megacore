# Normalização até a 3FN — EquipCheck Mini

## 1ª Forma Normal (1FN)

Atributos atômicos e sem grupos repetitivos.

- Todas as colunas guardam um único valor. Versões são texto único (`FW 2.1.0`), não listas.
- O histórico de versões e de correções não é guardado em colunas repetidas (`versao1`, `versao2`...), e sim em linhas de tabelas próprias (`historico_equipamento` e `historico_inspecao`).
- Não há atributos multivalorados.

**Resultado:** as quatro tabelas estão em 1FN.

## 2ª Forma Normal (2FN)

Sem dependências parciais em relação a uma chave composta.

- Todas as tabelas têm chave primária de uma única coluna (`id_equipamento`, `id_inspecao`, `id_historico`).
- Sem chave composta, não existe dependência parcial.

**Resultado:** as quatro tabelas estão em 2FN.

## 3ª Forma Normal (3FN)

Sem dependências transitivas entre atributos não chave.

### Dependências funcionais por tabela

| Tabela | Dependências funcionais |
|---|---|
| `equipamento` | `id_equipamento` → versao_firmware, versao_software, status, cadastrado_por, cadastrado_em, responsavel_alteracao, justificativa_alteracao |
| `inspecao` | `id_inspecao` → id_equipamento, medicao, aprovada, responsavel, observacao, versao_firmware, versao_software, data_hora, responsavel_alteracao, justificativa_alteracao |
| `historico_equipamento` | `id_historico` → id_equipamento, firmware_anterior, software_anterior, firmware_novo, software_novo, responsavel, justificativa, data_hora |
| `historico_inspecao` | `id_historico` → id_inspecao, medicao_anterior, medicao_nova, aprovada_anterior, aprovada_nova, observacao_nova, responsavel, justificativa, data_hora |

Verificação: nenhum atributo não chave determina outro atributo não chave, exceto nos casos discutidos abaixo.

## Decisões e redundâncias controladas

### 1. Versões de firmware e software em `inspecao`

Pode parecer que `versao_firmware` e `versao_software` dependem de `id_equipamento` (dependência transitiva `id_inspecao → id_equipamento → versões`). Não dependem: o equipamento muda de versão ao longo do tempo, e a inspeção guarda as versões **da época**. Duas inspeções do mesmo equipamento podem ter versões diferentes (nos dados de exemplo, EQP-001 foi inspecionado com `FW 2.1.0` e depois com `FW 2.2.0`). Logo, `id_equipamento` não determina as versões da inspeção. Elas são fato da própria inspeção e atendem ao RF06.

### 2. `historico_inspecao` sem colunas de versão

As versões associadas a uma correção são as da inspeção corrigida, e as versões de uma inspeção nunca mudam (trigger `trg_insp_bu`). Copiá-las em `historico_inspecao` criaria a dependência transitiva `id_historico → id_inspecao → versões`. Por isso a tabela **não** tem essas colunas: as versões são obtidas por `JOIN` com `inspecao` (consultas 9 e 12 de `sql/05-queries.sql`).

### 3. `classificacao` como coluna gerada `VIRTUAL`

A classificação é determinada pela medição (`medicao → classificacao`), o que seria uma dependência entre atributos não chave. Por isso ela é uma **coluna gerada virtual**: calculada na leitura e não armazenada, sem redundância no armazenamento. O usuário também não consegue informar um valor inconsistente.

### 4. `equipamento.status`

O status resulta de uma sequência de inspeções e aprovações (RF04): uma inspeção dentro da faixa e não aprovada não libera nem bloqueia por si só. Não é possível calculá-lo só a partir da última inspeção, então ele representa o **estado** do equipamento, mantido pelos triggers `trg_insp_ai` e `trg_insp_au`. Esse estado depende apenas de `id_equipamento`, sem dependência transitiva em outra coluna da tabela. A alternativa (recalcular varrendo todo o histórico a cada consulta) tornaria as consultas mais lentas e mais complexas.

### 5. `responsavel_alteracao` e `justificativa_alteracao`

Essas colunas, em `equipamento` e `inspecao`, são **parâmetros da operação**: o MySQL não permite passar argumentos a um `UPDATE` com trigger, então o responsável e a justificativa são enviados nas próprias colunas. Elas guardam a informação da última alteração, que também fica registrada nas tabelas de histórico. É uma redundância assumida por limitação técnica do MySQL. Uma alternativa futura é usar procedimentos armazenados com parâmetros, eliminando essas colunas.

## Conclusão

As quatro tabelas atendem à 1FN, 2FN e 3FN. As duas dependências que poderiam violar a 3FN (versões em `inspecao` e classificação) foram analisadas e resolvidas: as versões não dependem do equipamento, e a classificação é virtual. As únicas redundâncias mantidas (status e colunas de alteração) são conscientes e justificadas acima.
