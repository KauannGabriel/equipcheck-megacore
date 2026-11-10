## Povoamento DML (INSERT)

```sql
-- 1. Povoamento da tabela EQUIPAMENTO

INSERT INTO EQUIPAMENTO
(id_equipamento, versao_firmware, versao_software)
VALUES
(1, '1.0.2', '2.1.0'),
(2, '1.1.0', '2.2.0'),
(3, '1.2.0', '2.3.0');


-- 2. Povoamento da tabela RESPONSAVEL

INSERT INTO RESPONSAVEL
(id_responsavel, nome)
VALUES
(1, 'Carlos Mendes'),
(2, 'Ana Paula'),
(3, 'João Ferreira');


-- 3. Povoamento da tabela INSPECAO

INSERT INTO INSPECAO
(id_inspecao, id_equipamento, id_responsavel,
 medicao, status, justificativa, data_hora)
VALUES
(1, 1, 1, 15, 'APTO', NULL, '2026-11-10 08:30:00'),
(2, 2, 2, 18, 'APTO', NULL, '2026-11-10 09:15:00'),
(3, 3, 3, 8, 'BLOQUEADO', 'Medição abaixo do limite permitido',
 '2026-11-10 10:00:00'),
(4, 1, 2, 25, 'BLOQUEADO', 'Medição acima do limite permitido',
 '2026-11-10 11:20:00');
```