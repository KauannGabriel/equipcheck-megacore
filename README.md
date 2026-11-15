# EquipCheck Mini

Aplicativo de apoio ao registro de equipamentos e inspeções da **MegaCore Labs**, permitindo acompanhar a condição de liberação de cada equipamento, as versões de firmware e software associadas e o histórico de verificações e mudanças.

> Projeto A3 — Garantia da Qualidade de Software (UNA) · Cenário 5 MegaCore Labs

## Contexto

A MegaCore Labs, de Campinas, desenvolve software embarcado e aplicações de configuração para equipamentos médicos e industriais. Seus clientes exigem documentação e histórico das verificações. Firmware e aplicativo de configuração são produzidos por equipes diferentes, e uma combinação incompatível de versões pode levar a falhas de classificação: em um teste interno, uma combinação de firmware e aplicativo mostrou um equipamento como apto apesar de existir uma condição de bloqueio.

O EquipCheck Mini existe para registrar essas inspeções com rastreabilidade, preservando os controles necessários e a possibilidade de reconstruir o histórico de uma liberação.

### Indicadores fornecidos pela empresa (valores fictícios)

| Indicador | Valor |
|-----------|-------|
| Tempo de uma versão até liberação | 16 semanas |
| Tempo gasto em espera | 27% do tempo total |
| Requisitos ligados a testes | 95% |

Esses dados sustentam o diagnóstico junto com o relato do cenário, mas não determinam sozinhos a causa dos problemas.

## Requisitos funcionais

| ID | Requisito |
|----|-----------|
| RF01 | Cadastrar equipamento com identificador único e versões de firmware e software obrigatórias. |
| RF02 | Registrar uma medição numérica em inspeção, usando a faixa didática de 10 a 20, incluindo os extremos. |
| RF03 | Classificar como **Bloqueado** se a medição estiver fora da faixa; dentro dela, classificar como **Apto**. |
| RF04 | Permitir que um equipamento Bloqueado volte a Apto somente após nova inspeção aprovada. |
| RF05 | Exigir responsável e justificativa para alteração de versão ou de dados da inspeção. |
| RF06 | Preservar o histórico de inspeções e mudanças, incluindo as versões de firmware e software associadas a cada registro. |

## Modelo de dados

| Tabela | Função |
|--------|--------|
| `equipamento` | Equipamento (`EQP-001`), versões atuais de firmware e software e status (Apto/Bloqueado). |
| `inspecao` | Medição, classificação automática, aprovação, responsável e as versões vigentes no momento da inspeção. |
| `historico_equipamento` | Toda mudança de versão: valores anteriores e novos, responsável, justificativa e data/hora. |
| `historico_inspecao` | Toda correção de medição, aprovação ou observação, com responsável, justificativa e versões associadas. |
| `v_status_atual_equipamento` (view) | Situação atual de cada equipamento com a última inspeção. |

### Como cada requisito é garantido no banco

| Requisito | Mecanismo |
|-----------|-----------|
| RF01 | Chave primária, `CHECK` no formato do ID e `CHECK` de versões não vazias. |
| RF02 | `medicao DECIMAL(8,2) NOT NULL`. |
| RF03 | `classificacao` é coluna gerada (`GENERATED ... STORED`): `BETWEEN 10.00 AND 20.00` é Apto, o resto é Bloqueado. |
| RF04 | Triggers de `inspecao` atualizam `equipamento.status`: medição fora da faixa bloqueia; dentro da faixa só libera se `aprovada = 1`. |
| RF05 | Triggers `BEFORE UPDATE` rejeitam alterações sem `responsavel_alteracao` e `justificativa_alteracao` (mín. 10 caracteres, diferente da anterior). |
| RF06 | Triggers `AFTER INSERT/UPDATE` gravam nas tabelas de histórico; as versões são copiadas para cada inspeção; `DELETE` e `UPDATE` em históricos são bloqueados. |

### Premissas adotadas

- Equipamento recém-cadastrado nasce **Bloqueado** e só vira Apto após a primeira inspeção aprovada (escolha conservadora; o enunciado não define o estado inicial).
- A aprovação é o campo `aprovada` da inspeção, alterado com responsável e justificativa (RF05) e registrado no histórico.
- Apenas `medicao`, `aprovada` e `observacao` podem ser corrigidas em uma inspeção; equipamento, responsável original, data e versões são fixos.
- Nenhum registro de equipamento ou inspeção pode ser excluído.

## Tecnologias

- Banco de dados: MySQL 8.0.16+ (necessário para `CHECK` constraints aplicadas)
- Back-end: JavaScript (Node.js)
- Front-end: React

## Como executar

```bash
# Criar o banco, as tabelas, os triggers e a view
mysql -u root -p < sql/01_schema.sql
```

O final do arquivo traz comandos de teste comentados (um por requisito) para validar as regras.

## Estrutura do repositório

```
.
├── README.md
├── docs/        # modelo conceitual/lógico (DER)
└── sql/         # 01_schema.sql: tabelas, restrições, triggers e view
```

## Licença

_A definir._