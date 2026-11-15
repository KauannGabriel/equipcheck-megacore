USE equipcheck;

-- 1) Situação atual de cada equipamento (view)  [RF01, RF03, RF04]
SELECT * FROM v_status_atual_equipamento ORDER BY id_equipamento;

-- 2) Inspeções com o equipamento e as versões vigentes na época  [RF02, RF03, RF06]  (JOIN)
SELECT i.id_inspecao, e.id_equipamento, i.medicao, i.classificacao,
        i.aprovada, i.responsavel, i.versao_firmware, i.versao_software, i.data_hora
FROM inspecao i
JOIN equipamento e ON e.id_equipamento = i.id_equipamento
ORDER BY e.id_equipamento, i.id_inspecao;

-- 3) Equipamentos hoje Bloqueados com a última inspeção  [RF04]
SELECT id_equipamento, status_atual, ultima_medicao, ultima_classificacao, ultima_aprovada
FROM v_status_atual_equipamento
WHERE status_atual = 'Bloqueado';

-- 4) Resumo de inspeções por equipamento  [RF02]  (GROUP BY)
SELECT e.id_equipamento,
        COUNT(i.id_inspecao) AS total_inspecoes,
        MIN(i.medicao)       AS menor_medicao,
        MAX(i.medicao)       AS maior_medicao,
        ROUND(AVG(i.medicao), 2) AS media_medicao
FROM equipamento e
LEFT JOIN inspecao i ON i.id_equipamento = e.id_equipamento
GROUP BY e.id_equipamento
ORDER BY e.id_equipamento;

-- 5) Quantidade de inspeções por classificação  [RF03]  (GROUP BY)
SELECT classificacao, COUNT(*) AS total
FROM inspecao
GROUP BY classificacao;

-- 6) Equipamentos que nunca foram inspecionados  [RF04]  (LEFT JOIN)
SELECT e.id_equipamento, e.status
FROM equipamento e
LEFT JOIN inspecao i ON i.id_equipamento = e.id_equipamento
WHERE i.id_inspecao IS NULL;

-- 7) Histórico de mudanças de versão (inclui o cadastro inicial)  [RF05, RF06]
SELECT h.id_equipamento, h.firmware_anterior, h.firmware_novo,
        h.software_anterior, h.software_novo, h.responsavel, h.justificativa, h.data_hora
FROM historico_equipamento h
ORDER BY h.id_equipamento, h.id_historico;

-- 8) Equipamentos com mais de uma mudança de versão registrada  [RF06]  (HAVING)
SELECT id_equipamento, COUNT(*) AS registros
FROM historico_equipamento
GROUP BY id_equipamento
HAVING COUNT(*) > 1;

-- 9) Correções de inspeção com as versões associadas (via JOIN)  [RF05, RF06]
SELECT hi.id_historico, i.id_equipamento, hi.medicao_anterior, hi.medicao_nova,
        hi.aprovada_anterior, hi.aprovada_nova, i.versao_firmware, i.versao_software,
        hi.responsavel, hi.justificativa, hi.data_hora
FROM historico_inspecao hi
JOIN inspecao i ON i.id_inspecao = hi.id_inspecao
ORDER BY hi.id_historico;

-- 10) Inspeções fora da faixa por combinação de versões  [RF06, cenário do relato]  (GROUP BY)
SELECT i.versao_firmware, i.versao_software,
        COUNT(*) AS total_inspecoes,
        SUM(i.classificacao = 'Bloqueado') AS fora_da_faixa
FROM inspecao i
GROUP BY i.versao_firmware, i.versao_software
ORDER BY fora_da_faixa DESC, total_inspecoes DESC;

-- 11) Equipamentos hoje Aptos que já estiveram Bloqueados  [RF04]  (subconsulta)
SELECT e.id_equipamento
FROM equipamento e
WHERE e.status = 'Apto'
  AND EXISTS (SELECT 1 FROM inspecao i
                WHERE i.id_equipamento = e.id_equipamento
                  AND i.classificacao = 'Bloqueado');

-- 12) Reconstrução da linha do tempo de um equipamento  [RF06]  (UNION ALL)
--     Troque 'EQP-002' pelo equipamento desejado.
SELECT data_hora, 'Inspeção' AS evento,
        CONCAT('Medição ', medicao, ' (', classificacao, '), aprovada=', aprovada,
              ', por ', responsavel, ', FW ', versao_firmware, ' / SW ', versao_software) AS detalhe
FROM inspecao
WHERE id_equipamento = 'EQP-002'
UNION ALL
SELECT hi.data_hora, 'Correção de inspeção',
        CONCAT('Medição ', hi.medicao_anterior, ' -> ', hi.medicao_nova,
              ', aprovada ', hi.aprovada_anterior, ' -> ', hi.aprovada_nova,
              ', por ', hi.responsavel, ': ', hi.justificativa)
FROM historico_inspecao hi
JOIN inspecao i ON i.id_inspecao = hi.id_inspecao
WHERE i.id_equipamento = 'EQP-002'
UNION ALL
SELECT data_hora, 'Mudança de versão',
        CONCAT('FW ', COALESCE(firmware_anterior, '-'), ' -> ', firmware_novo,
              ', SW ', COALESCE(software_anterior, '-'), ' -> ', software_novo,
              ', por ', responsavel, ': ', justificativa)
FROM historico_equipamento
WHERE id_equipamento = 'EQP-002'
ORDER BY data_hora;