# Diagrama de Caso de Uso — EquipCheck Mini

## Atores

| Ator | Descrição |
|---|---|
| Inspetor / Técnico | Executa inspeções e registra as medições |
| Responsável técnico (Qualidade) | Aprova inspeções e justifica correções |
| Engenharia / Integração | Cadastra equipamentos e altera versões de firmware e software |

## Casos de uso

| ID | Caso de uso | Atores | Requisito |
|---|---|---|---|
| UC01 | Cadastrar equipamento | Engenharia / Integração | RF01 |
| UC02 | Consultar status dos equipamentos | Todos | RF03, RF04 |
| UC03 | Registrar inspeção | Inspetor / Técnico | RF02, RF03 |
| UC04 | Classificar medição (Apto / Bloqueado) | Incluído por UC03 | RF03 |
| UC05 | Aprovar inspeção | Responsável técnico | RF04, RF05 |
| UC06 | Corrigir dados de inspeção | Responsável técnico | RF05, RF06 |
| UC07 | Alterar versões de firmware e software | Engenharia / Integração | RF05, RF06 |
| UC08 | Atualizar status do equipamento | Incluído por UC03, UC05 e UC06 | RF04 |
| UC09 | Registrar responsável e justificativa | Incluído por UC05, UC06 e UC07 | RF05 |
| UC10 | Consultar histórico de inspeções e mudanças | Responsável técnico, Engenharia / Integração | RF06 |
| UC11 | Registrar histórico da mudança | Incluído por UC01, UC05, UC06 e UC07 | RF06 |

## Relações

- Todas as relações entre casos de uso do diagrama são `«include»`: a execução do caso de uso base sempre dispara o incluído.
- Não há relações `«extend»`, porque nenhum comportamento é opcional.

## Descrição textual dos casos de uso principais

### UC03 — Registrar inspeção

- **Ator principal:** Inspetor / Técnico.
- **Pré-condição:** o equipamento está cadastrado.
- **Fluxo principal:** o ator informa o equipamento, a medição e seu nome; o sistema grava a inspeção com as versões de firmware e software vigentes, classifica a medição (UC04) e atualiza o status do equipamento (UC08).
- **Fluxo alternativo:** se a medição estiver fora da faixa de 10 a 20, a classificação é Bloqueado e o equipamento passa a Bloqueado.
- **Fluxo de exceção:** equipamento inexistente ou responsável vazio: o registro é rejeitado.
- **Pós-condição:** inspeção gravada e status do equipamento atualizado.

### UC05 — Aprovar inspeção

- **Ator principal:** Responsável técnico.
- **Pré-condição:** existe uma inspeção ainda não aprovada.
- **Fluxo principal:** o ator marca a inspeção como aprovada informando seu nome e uma justificativa (UC09); o sistema grava a correção no histórico (UC11) e reavalia o status (UC08).
- **Fluxo alternativo:** se a inspeção aprovada estiver dentro da faixa e for a mais recente do equipamento, o equipamento volta a Apto.
- **Fluxo de exceção:** sem responsável ou com justificativa curta ou repetida, a aprovação é rejeitada.
- **Pós-condição:** aprovação registrada no histórico; equipamento Apto apenas se a regra RF04 for atendida.

### UC07 — Alterar versões de firmware e software

- **Ator principal:** Engenharia / Integração.
- **Pré-condição:** o equipamento está cadastrado.
- **Fluxo principal:** o ator informa as novas versões, seu nome e uma justificativa (UC09); o sistema atualiza o equipamento e grava no histórico os valores anteriores e novos (UC11).
- **Fluxo de exceção:** sem responsável ou justificativa válida, a alteração é rejeitada e nada é gravado.
- **Pós-condição:** novas inspeções passam a registrar as novas versões; inspeções antigas mantêm as versões da época.
