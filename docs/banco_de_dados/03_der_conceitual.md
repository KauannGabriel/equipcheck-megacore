# Diagrama Entidade-Relacionamento (DER Conceitual)
**Projeto:** EquipCheck Mini (MegaCore Labs)

## 1. Descrição do Modelo Conceitual
O modelo conceitual do *EquipCheck Mini* representa as entidades principais do domínio da MegaCore Labs e suas interações diretas:

* **EQUIPAMENTO:** Armazena os identificadores únicos dos equipamentos e as respetivas versões de firmware e software.
* **RESPONSAVEL:** Representa os operadores/técnicos que realizam os testes e inspeções.
* **INSPECAO:** Entidade central que regista as medições técnicas, os estados (Apto/Bloqueado), as justificativas e o carimbo de data/hora (timestamp).

## 2. Cardinalidades e Relacionamentos
* **EQUIPAMENTO possui INSPECAO (1:N):** Um equipamento pode passar por várias inspeções ao longo do tempo, mas cada registo de inspeção refere-se a apenas um equipamento específico.
* **RESPONSAVEL realiza INSPECAO (1:N):** Um responsável pode realizar múltiplas inspeções, contudo cada inspeção é executada e assinada por um único responsável.