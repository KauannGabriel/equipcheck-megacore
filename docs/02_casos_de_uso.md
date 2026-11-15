# Requisitos Funcionais e Casos de Uso
**Projeto:** EquipCheck Mini (MegaCore Labs)

## 1. Lista de Funcionalidades
O *EquipCheck Mini* tem como objetivo facilitar o controle das inspeções dos equipamentos da MegaCore Labs, automatizando a validação das medições e a classificação dos equipamentos. As funcionalidades implementadas são:
* Cadastro de equipamentos com identificador único.
* Registro das versões de firmware e software.
* Registro das medições realizadas durante as inspeções.
* Validação automática das medições entre 10 e 20.
* Classificação automática como Apto ou Bloqueado.
* Solicitação de justificativa quando o equipamento for bloqueado.
* Identificação do responsável pela inspeção.
* Registro do histórico de inspeções com data e hora.
* Consulta de equipamentos e histórico de inspeções.

## 2. Atores do Sistema
* **Responsável pela Inspeção:** Ator principal que realiza o cadastro de equipamentos, executa as inspeções, informa dados, justificativas e realiza consultas no sistema.

## 3. Descrição dos Casos de Uso (Visão Geral)
* **UC01 - Cadastrar equipamento:** Permite registar o equipamento no sistema com ID único.
* **UC02 - Registrar versões de firmware e software:** Associa as versões técnicas ao equipamento cadastrado (`«include»` de UC01).
* **UC03 - Realizar inspeção:** Processo principal onde o operador inicia a verificação técnica.
* **UC04 - Validar medição:** Valida estritamente se o valor está entre 10.00 e 20.00.
* **UC05 - Classificar status do equipamento:** Define automaticamente como *Apto* (se entre 10 e 20) ou *Bloqueado* (fora do intervalo).
* **UC06 - Informar justificativa:** Exigido obrigatoriamente caso o equipamento seja bloqueado (`«extend»` de UC03).
* **UC07 - Identificar responsável:** Regista quem realizou a inspeção.
* **UC08 - Registrar histórico da inspeção:** Guarda o registo imutável com data e hora (`TIMESTAMP`).
* **UC09 - Consultar equipamentos e histórico:** Permite pesquisar o estado e o histórico de inspeções anteriores.