# Escopo do Projeto — EquipCheck Mini

Projeto A3 · Bancos de Dados (UNA Betim) · Cenário 5 MegaCore Labs (Garantia da Qualidade de Software)

## 1. Domínio e problema

A MegaCore Labs, de Campinas, desenvolve software embarcado e aplicações de configuração para equipamentos médicos e industriais. A empresa tem 64 profissionais em engenharia, desenvolvimento de firmware, desenvolvimento de software, testes e qualidade regulatória. Seus clientes são fabricantes e integradores que exigem documentação e histórico das verificações.

Firmware e aplicativo de configuração são produzidos por equipes diferentes, com agendas nem sempre alinhadas, e os resultados de verificação ficam vinculados às versões produzidas. Em um teste interno recente, uma combinação de firmware e aplicativo mostrou um equipamento como apto apesar de existir uma condição de bloqueio. O produto não chegou ao mercado, mas foi necessário repetir parte importante da validação.

A empresa tem rastreabilidade forte e registros consistentes, mas enfrenta filas de aprovação e verificações repetitivas. A direção aceita automatizar atividades, desde que sejam preservados os controles necessários e a possibilidade de reconstruir o histórico de uma liberação.

**Problema que o banco de dados resolve:** registrar equipamentos, inspeções e mudanças de versão de forma consistente, classificar automaticamente a condição de liberação (Apto ou Bloqueado) e manter um histórico que permita reconstruir qualquer liberação.

### Indicadores fornecidos pela empresa (valores fictícios)

| Indicador | Valor |
|---|---|
| Tempo de uma versão até liberação | 16 semanas |
| Tempo gasto em espera | 27% do tempo total |
| Requisitos ligados a testes | 95% |

Esses dados sustentam o diagnóstico junto com o relato do cenário, mas não determinam sozinhos a causa dos problemas.

## 2. Objetivos

### Objetivos do sistema

- Apoiar o registro de equipamentos e inspeções.
- Permitir acompanhar a condição de liberação de cada equipamento.
- Associar as versões de firmware e software a cada registro.
- Manter o histórico das verificações e mudanças.

### Objetivos do banco de dados

- Garantir a integridade dos dados com chaves, restrições e triggers.
- Aplicar no próprio banco as regras de classificação, desbloqueio e justificativa obrigatória.
- Preservar histórico de mudanças que não possa ser apagado.
- Manter o modelo normalizado até a 3ª Forma Normal.

## 3. Limites do escopo

### Dentro do escopo

- Cadastro de equipamentos com identificador único e versões de firmware e software.
- Registro de inspeções com medição numérica e classificação automática.
- Aprovação de inspeções e regra de desbloqueio de equipamentos.
- Alteração de versões e de dados de inspeção com responsável e justificativa obrigatórios.
- Histórico de inspeções e mudanças, com as versões associadas a cada registro.
- Banco MySQL com scripts de criação, dados de exemplo e consultas de demonstração.
- Como complemento opcional: API em JavaScript (Node.js) e interface em React.

### Fora do escopo

- Integração com os equipamentos físicos ou leitura automática de medições.
- Fluxo completo de aprovação entre áreas (engenharia, qualidade regulatória, integração e aprovadores finais) descrito no relato da empresa.
- Gestão de requisitos de clientes, pacotes de liberação e documentação regulatória.
- Autenticação e perfis de acesso (o responsável é informado em cada operação).
- Cálculo real de calibração: a faixa de 10 a 20 é didática.

## 4. Público-alvo e usuários

| Papel | Interesse |
|---|---|
| Inspetor / técnico | Registrar inspeções e consultar a condição do equipamento |
| Responsável técnico / qualidade | Aprovar inspeções e justificar alterações |
| Engenharia e integração | Cadastrar equipamentos, alterar versões e consultar o histórico |
| Direção da MegaCore Labs | Reduzir filas e verificações repetitivas sem perder controle |
| Clientes (fabricantes e integradores) | Receber histórico confiável das verificações |

## 5. Principais entidades e relacionamentos

| Entidade | Descrição |
|---|---|
| Equipamento | Item verificado, com identificador único (`EQP-001`), versões atuais de firmware e software e status (Apto ou Bloqueado) |
| Inspeção | Verificação de um equipamento, com medição, aprovação, responsável e as versões vigentes na data |
| Alteração de versão | Registro de cada mudança de firmware ou software de um equipamento |
| Correção de inspeção | Registro de cada correção de medição, aprovação ou observação de uma inspeção |

| Relacionamento | Cardinalidade |
|---|---|
| Equipamento é inspecionado | 1 equipamento para N inspeções |
| Equipamento sofre alteração de versão | 1 equipamento para N alterações |
| Inspeção sofre correção | 1 inspeção para N correções |