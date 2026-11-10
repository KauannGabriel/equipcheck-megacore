# Especificação de Requisitos e Escopo de Qualidade
**Projeto:** EquipCheck Mini (MegaCore Labs)

## 1. Contexto e Problema Operacional
A **MegaCore Labs** enfrenta desafios na padronização e auditabilidade das medições de calibração dos seus equipamentos industriais. O *EquipCheck Mini* foi idealizado como uma solução para eliminar erros manuais de avaliação, impor regras operacionais rígidas e manter a rastreabilidade imutável de todas as inspeções.

## 2. Requisitos Funcionais e Regras de Qualidade
* **RF01 - Gestão de Equipamentos e Versões:** Registro único do equipamento associado obrigatoriamente à versão de *firmware* e *software*.
* **RF02 - Registro de Medições:** Coleta de dados numéricos durante o processo de inspeção técnica.
* **RF03 - Validação de Tolerância:** Restrição rigorosa das medições válidas no intervalo **entre 10.00 e 20.00**.
* **RF04 - Classificação Automática de Status:** Define o equipamento automaticamente como **Apto** (entre 10 e 20) ou **Bloqueado** (fora do intervalo).
* **RF05 - Responsável e Justificativa Obrigatória:** Registro da identidade do operador e obrigatoriedade de justificativa textual para bloqueios.
* **RF06 - Histórico Imutável:** Registro auditável com carimbo de data e hora (`TIMESTAMP`), sem permissão de alteração ou exclusão de registros passados.