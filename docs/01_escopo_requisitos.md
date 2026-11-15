# EquipCheck Mini — Escopo e Requisitos

Projeto A3 · Garantia da Qualidade de Software (UNA) · Cenário 5 MegaCore Labs

## 1. Contexto

A MegaCore Labs, de Campinas, desenvolve software embarcado e aplicações de configuração para equipamentos médicos e industriais. A empresa tem 64 profissionais em engenharia, desenvolvimento de firmware, desenvolvimento de software, testes e qualidade regulatória. Seus clientes são fabricantes e integradores que exigem documentação e histórico das verificações.

Firmware e aplicativo de configuração são produzidos por equipes diferentes, com agendas nem sempre alinhadas, e os resultados de verificação ficam vinculados às versões produzidas. Em um teste interno recente, uma combinação de firmware e aplicativo mostrou um equipamento como apto apesar de existir uma condição de bloqueio. O produto não chegou ao mercado, mas foi necessário repetir parte importante da validação.

A empresa tem rastreabilidade forte e registros consistentes, mas enfrenta filas de aprovação e verificações repetitivas. A direção aceita automatizar atividades, desde que sejam preservados os controles necessários e a possibilidade de reconstruir o histórico de uma liberação.

### Indicadores fornecidos (valores fictícios)

| Indicador | Valor |
|---|---|
| Tempo de uma versão até liberação | 16 semanas |
| Tempo gasto em espera | 27% do tempo total |
| Requisitos ligados a testes | 95% |

Esses dados sustentam o diagnóstico junto com o relato do cenário, mas não determinam sozinhos a causa dos problemas.

## 2. Objetivo do projeto

Desenvolver o **EquipCheck Mini**, aplicativo que apoia o registro de equipamentos e inspeções, permitindo acompanhar a condição de liberação de cada equipamento, as versões de firmware e software associadas e o histórico das verificações e mudanças.

## 3. Escopo

### 3.1 Dentro do escopo

- Cadastro de equipamentos com identificador único e versões de firmware e software.
- Registro de inspeções com medição numérica e classificação automática (Apto ou Bloqueado).
- Aprovação de inspeções e regra de desbloqueio de equipamentos.
- Alteração de versões e de dados de inspeção com responsável e justificativa obrigatórios.
- Histórico preservado de inspeções e mudanças, com as versões de firmware e software associadas a cada registro.
- Banco de dados MySQL, API em JavaScript (Node.js) e interface em React.
- Testes automatizados que relacionem requisitos, testes e riscos.

### 3.2 Fora do escopo

- Integração com os equipamentos físicos ou leitura automática de medições.
- Fluxo completo de aprovação entre áreas (engenharia, qualidade regulatória, integração, aprovadores finais) descrito no relato da empresa.
- Gestão de requisitos de clientes, pacotes de liberação e documentação regulatória.
- Autenticação e perfis de acesso (a identificação do responsável é informada em cada operação).
- Cálculo real de calibração: a faixa de 10 a 20 é didática.

## 4. Partes interessadas e usuários

| Papel | Interesse |
|---|---|
| Inspetor / técnico | Registrar inspeções e consultar a condição do equipamento |
| Responsável técnico / qualidade | Aprovar inspeções e justificar alterações |
| Engenharia e integração | Consultar versões de firmware e software associadas a cada registro |
| Direção da MegaCore Labs | Reduzir filas e verificações repetitivas sem perder controle |
| Clientes (fabricantes e integradores) | Receber histórico confiável das verificações |

## 5. Requisitos funcionais

| ID | Requisito |
|---|---|
| RF01 | Cadastrar equipamento com identificador único e versões de firmware e software obrigatórias. |
| RF02 | Registrar uma medição numérica em inspeção, usando a faixa didática de 10 a 20, incluindo os extremos. |
| RF03 | Classificar como Bloqueado se a medição estiver fora da faixa; dentro dela, classificar como Apto. |
| RF04 | Permitir que um equipamento Bloqueado volte a Apto somente após nova inspeção aprovada. |
| RF05 | Exigir responsável e justificativa para alteração de versão ou de dados da inspeção. |
| RF06 | Preservar o histórico de inspeções e mudanças, incluindo as versões de firmware e software associadas a cada registro. |

### Critérios de aceitação

| ID | Critério de aceitação |
|---|---|
| RF01 | Cadastro com ID repetido é rejeitado. Cadastro sem versão de firmware ou de software é rejeitado. O ID segue o formato `EQP-001`. |
| RF02 | A medição é gravada como número decimal. Valor não numérico é rejeitado. |
| RF03 | 10.00 e 20.00 resultam em Apto. 9.99 e 20.01 resultam em Bloqueado. A classificação não é informada pelo usuário. |
| RF04 | Após uma inspeção fora da faixa, o equipamento fica Bloqueado. Uma nova inspeção dentro da faixa sem aprovação não o libera. Uma nova inspeção dentro da faixa e aprovada o devolve a Apto. |
| RF05 | Alterar versão ou dados de uma inspeção sem responsável ou sem justificativa é rejeitado. A justificativa deve ser detalhada (mínimo de 10 caracteres) e nova a cada alteração. |
| RF06 | Cada inspeção guarda as versões de firmware e software vigentes. Cada mudança de versão ou de dados de inspeção gera um registro de histórico com valor anterior, valor novo, responsável, justificativa e data e hora. Registros de histórico não podem ser alterados nem excluídos. |

## 6. Requisitos não funcionais (proposta da equipe)

O enunciado não traz requisitos não funcionais. Os itens abaixo são propostos pela equipe e devem ser validados.

| ID | Requisito | Descrição |
|---|---|---|
| RNF01 | Integridade | As regras de negócio são garantidas no banco (restrições e triggers) e validadas na API. |
| RNF02 | Rastreabilidade | Todo registro de histórico possui data e hora (`TIMESTAMP`) e responsável. |
| RNF03 | Testabilidade | Cada requisito funcional possui ao menos um teste automatizado. |
| RNF04 | Usabilidade | Mensagens de erro claras, incluindo a tradução das mensagens dos triggers. |
| RNF05 | Portabilidade | O ambiente sobe a partir do repositório com um script de criação do banco e variáveis de ambiente. |
| RNF06 | Manutenibilidade | Código em camadas (rotas, serviços, repositórios) e padronizado com ESLint e Prettier. |

## 7. Regras de negócio

- **RN01:** o status do equipamento nunca é informado manualmente; é consequência das inspeções.
- **RN02:** a classificação da medição é Apto se estiver entre 10.00 e 20.00, inclusive, e Bloqueado caso contrário.
- **RN03:** um equipamento Bloqueado só volta a Apto após uma nova inspeção dentro da faixa e aprovada.
- **RN04:** toda alteração de versão ou de dados de inspeção exige responsável e justificativa.
- **RN05:** equipamentos e inspeções não são excluídos.
- **RN06:** em uma inspeção, somente medição, aprovação e observação podem ser corrigidas; equipamento, responsável original, data e versões são fixos.

## 8. Premissas e restrições

- Prazo de desenvolvimento: duas semanas.
- Tecnologias: MySQL 8.0.16 ou superior, JavaScript (Node.js) e React.
- Prioridade: back-end e banco de dados; o front-end é opcional, mas será desenvolvido.
- Equipamento recém-cadastrado nasce Bloqueado até a primeira inspeção aprovada (escolha conservadora da equipe).
- A aprovação é registrada no campo `aprovada` da inspeção e alterada com responsável e justificativa.
- A faixa de 10 a 20 é didática e fixa no sistema.

## 9. Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Combinação de versões classificar equipamento como Apto apesar de condição de bloqueio | Liberação indevida de equipamento | Guardar versões em cada inspeção e testar o cenário do relato |
| Regras duplicadas entre API e banco divergirem | Comportamento inconsistente | O banco é a fonte da verdade; a API só pré-valida e traduz erros |
| Prazo curto de duas semanas | Entrega incompleta | Priorizar back-end e banco; cortar o front por ordem de prioridade |
| Justificativas genéricas para cumprir a regra | Histórico sem valor de auditoria | Mínimo de caracteres e justificativa diferente da anterior |
| Falta de autenticação | Responsável informado pode não ser o real | Registrar como limitação e propor autenticação como melhoria |

## 10. Pontos em aberto

- Quem pode aprovar uma inspeção: qualquer usuário ou um perfil específico?
- O estado inicial de um equipamento novo deve ser Bloqueado?
- A faixa de 10 a 20 pode variar por tipo de equipamento no futuro?
- Como a equipe deseja identificar o responsável sem autenticação?

## 11. Rastreabilidade inicial

| Requisito | Risco relacionado | Verificação planejada |
|---|---|---|
| RF01 | Cadastro de equipamento sem versão compromete a rastreabilidade | Testes de cadastro com ID duplicado e versão vazia |
| RF02 | Medição inválida entra no histórico | Testes com valores numéricos e não numéricos |
| RF03 | Classificação errada libera equipamento fora da faixa | Testes de borda: 9.99, 10.00, 20.00 e 20.01 |
| RF04 | Equipamento bloqueado liberado sem nova inspeção aprovada | Testes do ciclo bloqueio, inspeção sem aprovação e inspeção aprovada |
| RF05 | Mudança sem responsável ou justificativa | Testes de alteração sem campos, com justificativa curta e repetida |
| RF06 | Impossibilidade de reconstruir a liberação | Testes de histórico de versões e inspeções e tentativa de exclusão |