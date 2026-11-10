# Entrega 1 — Banco de Dados: Escopo e Requisitos
**Projeto:** EquipCheck Mini (MegaCore Labs)

## 1. Contexto e Domínio
A **MegaCore Labs** é uma empresa industrial/laboratorial que necessita padronizar e automatizar o processo de verificação e calibração dos seus equipamentos. O **EquipCheck Mini** é um sistema desenvolvido para registrar inspeções técnicas, validar parâmetros de tolerância operacional, aplicar regras rígidas de qualidade e manter um histórico auditável e imutável.

## 2. Requisitos Funcionais do Sistema (RF01 a RF06)
* **RF01 - Gestão de Equipamentos e Versões:** Cadastro único de equipamentos (ex: `EQP-001`), associando obrigatoriamente a versão de *firmware* e a versão de *software* em uso.
* **RF02 - Registro de Medições:** Coleta de medição numérica durante o processo de inspeção técnica.
* **RF03 - Validação de Tolerância:** Restrição rigorosa das medições válidas no intervalo **entre 10.00 e 20.00**.
* **RF04 - Classificação Automática de Status:** 
  * Medições entre 10 e 20 definem o equipamento como **Apto**.
  * Medições fora do intervalo definem o equipamento como **Bloqueado**.
* **RF05 - Responsável e Justificativa Obrigatória:** Registro do responsável pela inspeção e obrigatoriedade de justificativa textual detalhada para equipamentos com status **Bloqueado**.
* **RF06 - Histórico Imutável:** Manutenção de histórico persistente de todas as inspeções contendo data e hora (`TIMESTAMP`), impedindo alterações de registros passados.