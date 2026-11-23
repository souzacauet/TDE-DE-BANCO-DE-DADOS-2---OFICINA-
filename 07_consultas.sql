use oficina;

-- ==================================================
-- CONSULTA 01: Historico detalhado de movimentacoes
-- Exibe as movimentacoes com dados das pecas,
-- fornecedores e ordens de servico.
-- ===================================================

SELECT
    me.id_movimentacao,
    me.data_movimentacao,
    me.tipo_movimentacao,
    me.quantidade,
    p.codigo AS codigo_peca,
    p.descricao AS nome_peca,
    f.razao_social AS fornecedor,
    os.id_ordem AS ordem_servico
FROM movimentacoes_estoque AS me
INNER JOIN pecas AS p
    ON me.id_peca = p.id_peca
LEFT JOIN fornecedores AS f
    ON me.id_fornecedor = f.id_fornecedor
LEFT JOIN ordens_servico AS os
    ON me.id_ordem = os.id_ordem
ORDER BY me.data_movimentacao DESC
LIMIT 20;

-- =============================================
-- CONSULTA 02
-- Relatorio geral das ordens de servico,
-- incluindo cliente, veiculo e valores.
-- ==============================================

SELECT
    os.id_ordem AS numero_ordem,
    c.nome AS cliente,
    v.marca,
    v.modelo,
    v.placa,
    os.data_abertura,
    os.status,
    os.valor_total
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.id_veiculo = v.id_veiculo
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
ORDER BY os.data_abertura DESC;

-- ========================================
-- CONSULTA 03: Faturamento mensal da oficina
-- ==========================================

SELECT
    DATE_FORMAT(p.data_pagamento, '%Y-%m') AS mes,
    COUNT(DISTINCT os.id_ordem) AS ordens_com_pagamento,
    COUNT(p.id_pagamento) AS quantidade_pagamentos,
    SUM(p.valor) AS faturamento_total
FROM pagamentos p
INNER JOIN ordens_servico os
    ON p.id_ordem = os.id_ordem
INNER JOIN veiculos v
    ON os.id_veiculo = v.id_veiculo
WHERE p.status = 'Confirmado'
GROUP BY DATE_FORMAT(p.data_pagamento, '%Y-%m')
HAVING SUM(p.valor) > 0
ORDER BY mes;

-- ====================================================
-- CONSULTA 04: Ranking dos serviços mais realizados
-- =====================================================

SELECT
    s.id_servico,
    s.descricao AS servico,
    SUM(isv.quantidade) AS quantidade_realizada,
    COUNT(DISTINCT isv.id_ordem) AS ordens_atendidas,
    SUM(isv.subtotal) AS faturamento_servico
FROM itens_servico isv
INNER JOIN servicos s
    ON isv.id_servico = s.id_servico
INNER JOIN ordens_servico os
    ON isv.id_ordem = os.id_ordem
GROUP BY
    s.id_servico,
    s.descricao
ORDER BY quantidade_realizada DESC;

-- ============================================
-- CONSULTA 05: Ranking das peças mais utilizadas nas ordens de serviço
-- ===============================================

SELECT
    p.id_peca,
    p.descricao AS peca,
    SUM(po.quantidade) AS quantidade_utilizada,
    COUNT(DISTINCT po.id_ordem) AS ordens_atendidas,
    SUM(po.subtotal) AS valor_total_pecas
FROM pecas_ordem po
INNER JOIN pecas p
    ON po.id_peca = p.id_peca
INNER JOIN ordens_servico os
    ON po.id_ordem = os.id_ordem
GROUP BY
    p.id_peca,
    p.descricao
ORDER BY quantidade_utilizada DESC;

-- ===========================================
-- CONSULTA 06: Desempenho dos mecânicos
-- =========================================

SELECT
    m.id_mecanico,
    m.nome AS mecanico,
    COUNT(DISTINCT om.id_ordem) AS total_ordens,
    SUM(om.horas_trabalhadas) AS total_horas_trabalhadas,
    COUNT(DISTINCT CASE
        WHEN os.status = 'Concluida' THEN os.id_ordem
    END) AS ordens_concluidas
FROM ordem_mecanico om
INNER JOIN mecanicos m
    ON om.id_mecanico = m.id_mecanico
INNER JOIN ordens_servico os
    ON om.id_ordem = os.id_ordem
GROUP BY
    m.id_mecanico,
    m.nome
ORDER BY total_ordens DESC;

-- ================================================
-- CONSULTA 07: Ranking dos clientes que mais gastaram
-- =================================================

SELECT
    c.id_cliente,
    c.nome AS cliente,
    COUNT(DISTINCT os.id_ordem) AS total_ordens,
    SUM(p.valor) AS total_gasto,
    MAX(p.data_pagamento) AS ultimo_pagamento
FROM clientes c
INNER JOIN veiculos v
    ON c.id_cliente = v.id_cliente
INNER JOIN ordens_servico os
    ON v.id_veiculo = os.id_veiculo
INNER JOIN pagamentos p
    ON os.id_ordem = p.id_ordem
WHERE p.status = 'Confirmado'
GROUP BY
    c.id_cliente,
    c.nome
ORDER BY total_gasto DESC;

-- ==============================================
-- CONSULTA 08: Ordens de serviço pendentes
-- ===============================================

SELECT
    os.id_ordem,
    c.nome AS cliente,
    v.placa,
    v.marca,
    v.modelo,
    os.data_abertura,
    os.status,
    m.nome AS mecanico
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.id_veiculo = v.id_veiculo
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente
LEFT JOIN ordem_mecanico om
    ON os.id_ordem = om.id_ordem
LEFT JOIN mecanicos m
    ON om.id_mecanico = m.id_mecanico
WHERE os.status <> 'Concluida'
ORDER BY os.data_abertura ASC;

-- ========================================
-- CONSULTA 09: Fornecedores e preços das peças
-- ========================================

SELECT
    f.id_fornecedor,
    f.razao_social AS fornecedor,
    p.id_peca,
    p.descricao AS peca,
    fp.preco_compra,
    fp.prazo_entrega_dias
FROM fornecedor_peca fp
INNER JOIN fornecedores f
    ON fp.id_fornecedor = f.id_fornecedor
INNER JOIN pecas p
    ON fp.id_peca = p.id_peca
ORDER BY
    p.descricao ASC,
    fp.preco_compra ASC;

-- =====================================
-- CONSULTA 10: Ticket médio das ordens de serviço
-- ======================================

SELECT
    COUNT(id_ordem) AS total_ordens,
    SUM(valor_total) AS faturamento_total,
    ROUND(AVG(valor_total), 2) AS ticket_medio
FROM ordens_servico
WHERE valor_total > 0;
