# Diagrama Entidade-Relacionamento (DER) Conceitual — EquipCheck Mini

## Entidades e atributos

| Entidade | Identificador | Atributos |
|---|---|---|
| Equipamento | `id_equipamento` | versão de firmware, versão de software, status, cadastrado por, cadastrado em |
| Inspeção | `id_inspecao` | medição, classificação (derivado), aprovada, responsável, observação, data e hora, versão de firmware vigente, versão de software vigente |
| Alteração de versão | `id_historico` | firmware anterior, software anterior, firmware novo, software novo, responsável, justificativa, data e hora |
| Correção de inspeção | `id_historico` | medição anterior, medição nova, aprovada anterior, aprovada nova, observação nova, responsável, justificativa, data e hora |

## Relacionamentos

| Relacionamento | Entidades | Cardinalidade | Participação |
|---|---|---|---|
| é inspecionado | Equipamento — Inspeção | 1:N | Inspeção total (toda inspeção pertence a um equipamento); Equipamento parcial |
| sofre alteração | Equipamento — Alteração de versão | 1:N | Alteração total; Equipamento parcial |
| sofre correção | Inspeção — Correção de inspeção | 1:N | Correção total; Inspeção parcial |

## Observações de modelagem

- **Atributo derivado:** `classificação` é calculada a partir da medição (Apto entre 10.00 e 20.00, inclusive).
- **Atributos multivalorados:** não há.
- **Relacionamentos N:N e entidades associativas:** não há; todos os relacionamentos são 1:N.
- **Entidades de histórico:** *Alteração de versão* e *Correção de inspeção* existem para atender RF05 e RF06 e só admitem inserção.
- **Versões vigentes na inspeção:** são atributos da inspeção porque registram as versões da época, e o equipamento muda de versão ao longo do tempo.
