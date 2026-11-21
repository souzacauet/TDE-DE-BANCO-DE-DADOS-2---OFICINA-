CREATE database oficina;
USE oficina;

-- =====================================================
-- 01. TABELA: CLIENTES
-- =====================================================
CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(120),
    data_cadastro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


-- =====================================================
-- 02. TABELA: MECANICOS
-- =====================================================
CREATE TABLE mecanicos (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf CHAR(11) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;


-- =====================================================
-- 03. TABELA: SERVICOS
-- =====================================================
CREATE TABLE servicos (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL,
    detalhes TEXT,
    valor_mao_obra DECIMAL(10,2) NOT NULL,
    tempo_estimado_min INT NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT chk_servico_valor
        CHECK (valor_mao_obra >= 0),

    CONSTRAINT chk_servico_tempo
        CHECK (tempo_estimado_min > 0)
) ENGINE=InnoDB;


-- =====================================================
-- 04. TABELA: PECAS
-- =====================================================
CREATE TABLE pecas (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    descricao VARCHAR(150) NOT NULL,
    fabricante VARCHAR(100),
    preco_venda DECIMAL(10,2) NOT NULL,
    custo_medio DECIMAL(10,2) NOT NULL,

    CONSTRAINT chk_peca_preco
        CHECK (preco_venda >= 0),

    CONSTRAINT chk_peca_custo
        CHECK (custo_medio >= 0)
) ENGINE=InnoDB;


-- =====================================================
-- 05. TABELA: FORNECEDORES
-- =====================================================
CREATE TABLE fornecedores (
    id_fornecedor INT AUTO_INCREMENT PRIMARY KEY,
    razao_social VARCHAR(150) NOT NULL,
    cnpj CHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20) NOT NULL,
    email VARCHAR(120)
) ENGINE=InnoDB;

-- ======================================================
-- 06. TABELA: VEICULOS
-- ======================================================
CREATE TABLE veiculos (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    placa VARCHAR(10) NOT NULL UNIQUE,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    ano INT NOT NULL,
    cor VARCHAR(30),
    quilometragem INT NOT NULL DEFAULT 0,

    CONSTRAINT fk_veiculos_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_veiculo_ano
        CHECK (ano >= 1900 AND ano <= 2100),

    CONSTRAINT chk_veiculo_km
        CHECK (quilometragem >= 0)
) ENGINE=InnoDB;
-- ======================================================
-- 07. TABELA: AGENDAMENTOS
-- ====================================================== 
CREATE TABLE agendamentos (
    id_agendamento INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    data_hora DATETIME NOT NULL,
    descricao VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'Agendado',

    CONSTRAINT fk_agendamentos_veiculo
        FOREIGN KEY (id_veiculo)
        REFERENCES veiculos(id_veiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB;
-- ====================================================
-- 08. TABELA: ORDEM DE SERVIÇOS
-- ====================================================
CREATE TABLE ordens_servico (
    id_ordem INT AUTO_INCREMENT PRIMARY KEY,
    id_veiculo INT NOT NULL,
    data_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_fechamento DATETIME,
    status VARCHAR(30) NOT NULL DEFAULT 'Aberta',
    descricao_problema TEXT,
    observacoes TEXT,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,

    CONSTRAINT fk_ordens_veiculo
        FOREIGN KEY (id_veiculo)
        REFERENCES veiculos(id_veiculo)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_ordem_valor
        CHECK (valor_total >= 0),

    CONSTRAINT chk_ordem_datas
        CHECK (
            data_fechamento IS NULL
            OR data_fechamento >= data_abertura
        )
) ENGINE=InnoDB;
-- =================================================
-- 09. ORDEM DAS PEÇAS
-- =================================================
CREATE TABLE pecas_ordem (
    id_peca_ordem INT AUTO_INCREMENT PRIMARY KEY,
    id_ordem INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL,
    valor_unitario DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(10,2)
        GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,

    CONSTRAINT fk_pecas_ordem_ordem
        FOREIGN KEY (id_ordem)
        REFERENCES ordens_servico(id_ordem)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_pecas_ordem_peca
        FOREIGN KEY (id_peca)
        REFERENCES pecas(id_peca)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_pecas_ordem_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT chk_pecas_ordem_valor
        CHECK (valor_unitario >= 0)
) ENGINE=InnoDB;
-- ====================================================
-- 10. TABELA: PAGAMENTOS
-- ====================================================
CREATE TABLE pagamentos (
    id_pagamento INT AUTO_INCREMENT PRIMARY KEY,
    id_ordem INT NOT NULL,
    data_pagamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor DECIMAL(10,2) NOT NULL,
    forma_pagamento VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Confirmado',
    observacoes VARCHAR(255),

    CONSTRAINT fk_pagamentos_ordem
        FOREIGN KEY (id_ordem)
        REFERENCES ordens_servico(id_ordem)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_pagamentos_valor
        CHECK (valor > 0),

    CONSTRAINT chk_pagamentos_status
        CHECK (status IN ('Confirmado', 'Pendente', 'Estornado'))
) ENGINE=InnoDB;
-- ===================================================================
-- 11. TABELA: ORDEM DOS MECANICOS
-- ===================================================================
CREATE TABLE ordem_mecanico (
    id_ordem INT NOT NULL,
    id_mecanico INT NOT NULL,
    data_alocacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    horas_trabalhadas DECIMAL(5,2) DEFAULT 0.00,
    observacoes VARCHAR(255),

    PRIMARY KEY (id_ordem, id_mecanico),

    CONSTRAINT fk_ordem_mecanico_ordem
        FOREIGN KEY (id_ordem)
        REFERENCES ordens_servico(id_ordem)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_ordem_mecanico_mecanico
        FOREIGN KEY (id_mecanico)
        REFERENCES mecanicos(id_mecanico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_ordem_mecanico_horas
        CHECK (horas_trabalhadas >= 0)
) ENGINE=InnoDB;
-- ==================================================================
-- 12. TABELA: FORNECEDORES DE PEÇAS
-- ==================================================================
CREATE TABLE fornecedor_peca (
    id_fornecedor INT NOT NULL,
    id_peca INT NOT NULL,
    preco_compra DECIMAL(10,2) NOT NULL,
    prazo_entrega_dias INT DEFAULT 0,

    PRIMARY KEY (id_fornecedor, id_peca),

    CONSTRAINT fk_fornecedor_peca_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedores(id_fornecedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_fornecedor_peca_peca
        FOREIGN KEY (id_peca)
        REFERENCES pecas(id_peca)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_fornecedor_peca_preco
        CHECK (preco_compra >= 0),

    CONSTRAINT chk_fornecedor_peca_prazo
        CHECK (prazo_entrega_dias >= 0)
) ENGINE=InnoDB;
-- ============================================================
-- 13. TABELA: ITENS DE SERVIÇO
-- ===========================================================
CREATE TABLE itens_servico (
    id_item_servico INT AUTO_INCREMENT PRIMARY KEY,
    id_ordem INT NOT NULL,
    id_servico INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,

    subtotal DECIMAL(10,2)
        GENERATED ALWAYS AS (quantidade * valor_unitario) STORED,

    CONSTRAINT fk_itens_servico_ordem
        FOREIGN KEY (id_ordem)
        REFERENCES ordens_servico(id_ordem)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_itens_servico_servico
        FOREIGN KEY (id_servico)
        REFERENCES servicos(id_servico)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_itens_servico_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT chk_itens_servico_valor
        CHECK (valor_unitario >= 0)
) ENGINE=InnoDB;
-- =================================================
-- 14. TABELA: MOVIMENTAÇÕES DE ESTOQUE
-- ================================================
CREATE TABLE movimentacoes_estoque (
    id_movimentacao INT AUTO_INCREMENT PRIMARY KEY,
    id_peca INT NOT NULL,
    id_fornecedor INT,
    id_ordem INT,
    tipo_movimentacao VARCHAR(20) NOT NULL,
    quantidade INT NOT NULL,
    data_movimentacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo VARCHAR(255) NOT NULL,

    CONSTRAINT fk_movimentacoes_peca
        FOREIGN KEY (id_peca)
        REFERENCES pecas(id_peca)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_movimentacoes_fornecedor
        FOREIGN KEY (id_fornecedor)
        REFERENCES fornecedores(id_fornecedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_movimentacoes_ordem
        FOREIGN KEY (id_ordem)
        REFERENCES ordens_servico(id_ordem)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_movimentacoes_tipo
        CHECK (tipo_movimentacao IN ('Entrada', 'Saida', 'Ajuste')),

    CONSTRAINT chk_movimentacoes_quantidade
        CHECK (quantidade > 0)
) ENGINE=InnoDB;

-- ================================================
--  FAZENDO O INSERT DE CLIENTES
-- ================================================

INSERT INTO clientes (nome, cpf, telefone, email)
VALUES
('Carlos Eduardo Mendes', '10000000001', '98981000001', 'carlos.mendes@email.com'),
('Mariana Costa Silva', '10000000002', '98981000002', 'mariana.costa@email.com'),
('Rafael Oliveira Santos', '10000000003', '98981000003', 'rafael.oliveira@email.com'),
('Juliana Ferreira Lima', '10000000004', '98981000004', 'juliana.ferreira@email.com'),
('Pedro Henrique Rocha', '10000000005', '98981000005', 'pedro.rocha@email.com'),
('Fernanda Alves Sousa', '10000000006', '98981000006', 'fernanda.alves@email.com'),
('Lucas Martins Ribeiro', '10000000007', '98981000007', 'lucas.martins@email.com'),
('Camila Rodrigues Nunes', '10000000008', '98981000008', 'camila.rodrigues@email.com');

-- =================================================
-- INSERT DOS MECANICOS
-- =================================================

INSERT INTO mecanicos (nome, cpf, telefone, especialidade, ativo)
VALUES
('Roberto Carlos Almeida', '20000000001', '98982000001', 'Motor e retifica', TRUE),
('Anderson Felipe Souza', '20000000002', '98982000002', 'Suspensao', TRUE),
('Marcos Vinicius Lima', '20000000003', '98982000003', 'Freios', TRUE),
('Thiago Pereira Costa', '20000000004', '98982000004', 'Eletrica automotiva', TRUE),
('Diego Fernandes Rocha', '20000000005', '98982000005', 'Injecao eletronica', TRUE),
('Paulo Henrique Santos', '20000000006', '98982000006', 'Cambio e transmissao', TRUE),
('Alexandre Moura Ribeiro', '20000000007', '98982000007', 'Ar condicionado automotivo', TRUE),
('Bruno Carvalho Mendes', '20000000008', '98982000008', 'Diagnostico automotivo', FALSE);

-- ==============================================
-- INSERT DOS SERVICOS
-- ==============================================

INSERT INTO servicos (descricao, detalhes, valor_mao_obra, tempo_estimado_min, ativo)
VALUES
('Troca de oleo', 'Drenagem e substituicao do oleo do motor e filtro.', 80.00, 40, TRUE),
('Alinhamento', 'Alinhamento da geometria das rodas dianteiras.', 100.00, 50, TRUE),
('Balanceamento', 'Balanceamento das rodas para reduzir vibracoes.', 80.00, 40, TRUE),
('Revisao de freios', 'Inspecao e manutencao do sistema de freios.', 180.00, 120, TRUE),
('Diagnostico eletronico', 'Leitura e analise de falhas com scanner automotivo.', 150.00, 60, TRUE),
('Troca de correia dentada', 'Remocao e instalacao da correia dentada.', 350.00, 180, TRUE),
('Revisao de suspensao', 'Inspecao dos componentes e folgas da suspensao.', 220.00, 120, TRUE),
('Higienizacao de ar condicionado', 'Limpeza e higienizacao do sistema de climatizacao.', 130.00, 90, FALSE);

-- ==============================================
-- INSERT DAS PECAS
-- ==============================================

INSERT INTO pecas (codigo, descricao, fabricante, preco_venda, custo_medio)
VALUES
('PC001', 'Filtro de oleo', 'Tecfil', 45.90, 28.50),
('PC002', 'Filtro de ar do motor', 'Mann Filter', 69.90, 42.00),
('PC003', 'Pastilha de freio dianteira', 'Bosch', 189.90, 125.00),
('PC004', 'Disco de freio dianteiro', 'Fremax', 320.00, 215.00),
('PC005', 'Correia dentada', 'Gates', 159.90, 98.00),
('PC006', 'Amortecedor dianteiro', 'Monroe', 480.00, 345.00),
('PC007', 'Vela de ignicao', 'NGK', 39.90, 24.00),
('PC008', 'Bateria automotiva 60Ah', 'Moura', 580.00, 435.00);

-- =================================================
-- INSERT DOS FORNECEDORES
-- =================================================

INSERT INTO fornecedores (razao_social, cnpj, telefone, email)
VALUES
('Auto Pecas Norte Distribuidora Ltda', '30000000000001', '98330000001', 'contato@autonorte.com.br'),
('Maranhao Automotive Supply Ltda', '30000000000002', '98330000002', 'vendas@maranhaoauto.com.br'),
('Distribuidora Central de Pecas Ltda', '30000000000003', '98330000003', 'central@pecas.com.br'),
('Motor Forte Componentes Automotivos Ltda', '30000000000004', '98330000004', 'motorforte@fornecedor.com.br'),
('Pecas Express Comercio Ltda', '30000000000005', '98330000005', 'pedidos@pecasexpress.com.br'),
('Premium Auto Componentes Ltda', '30000000000006', '98330000006', 'premium@autocomponentes.com.br'),
('Via Automotiva Distribuidora Ltda', '30000000000007', '98330000007', 'vendas@viaautomotiva.com.br'),
('Universal Pecas e Acessorios Ltda', '30000000000008', '98330000008', 'universal@pecas.com.br');

-- ================================================
-- INSERT DOS VEICULOS
-- ================================================

INSERT INTO veiculos (
    id_cliente, placa, marca, modelo, ano, cor, quilometragem
)
VALUES
(1, 'BRA1A01', 'Toyota', 'Corolla', 2022, 'Prata', 35000),
(2, 'BRA1A02', 'Honda', 'Civic', 2021, 'Preto', 42000),
(3, 'BRA1A03', 'Chevrolet', 'Onix', 2023, 'Branco', 18000),
(4, 'BRA1A04', 'Hyundai', 'HB20', 2020, 'Vermelho', 57000),
(5, 'BRA1A05', 'Volkswagen', 'Polo', 2022, 'Cinza', 31000),
(6, 'BRA1A06', 'Fiat', 'Argo', 2021, 'Azul', 46000),
(7, 'BRA1A07', 'Nissan', 'Kicks', 2023, 'Branco', 22000),
(8, 'BRA1A08', 'Jeep', 'Renegade', 2020, 'Preto', 64000);

-- ==================================================
-- INSERT DOS AGENDAMENTOS
-- ==================================================

INSERT INTO agendamentos (
    id_veiculo, data_hora, descricao, status
)
VALUES
(1, '2026-11-20 08:00:00', 'Troca de oleo e filtro', 'Agendado'),
(2, '2026-11-20 09:30:00', 'Verificacao do sistema de freios', 'Agendado'),
(3, '2026-11-20 10:30:00', 'Diagnostico de falha no motor', 'Confirmado'),
(4, '2026-11-21 08:00:00', 'Revisao preventiva', 'Agendado'),
(5, '2026-11-21 10:00:00', 'Alinhamento e balanceamento', 'Confirmado'),
(6, '2026-11-22 09:00:00', 'Verificacao da suspensao', 'Agendado'),
(7, '2026-11-23 08:30:00', 'Revisao do ar condicionado', 'Agendado'),
(8, '2026-11-23 11:00:00', 'Inspecao geral do veiculo', 'Cancelado');

-- ===========================================
-- INSERT DAS ORDENS DE SERVICO
-- ============================================

INSERT INTO ordens_servico (
    id_veiculo,
    data_abertura,
    data_fechamento,
    status,
    descricao_problema,
    observacoes,
    valor_total
)
VALUES
(1, '2026-11-10 08:00:00', '2026-11-10 10:00:00', 'Concluida', 'Motor apresentando ruido e necessidade de troca de oleo', 'Servico realizado e veiculo liberado', 245.90),
(2, '2026-11-11 09:00:00', '2026-11-11 12:00:00', 'Concluida', 'Desgaste nas pastilhas de freio', 'Pastilhas substituidas', 389.90),
(3, '2026-11-12 08:30:00', '2026-11-12 11:30:00', 'Concluida', 'Revisao preventiva do veiculo', 'Revisao concluida sem problemas graves', 299.80),
(4, '2026-11-13 10:00:00', NULL, 'Em andamento', 'Falha no sistema de injecao', 'Aguardando diagnostico complementar', 150.00),
(5, '2026-11-14 08:00:00', '2026-11-14 11:00:00', 'Concluida', 'Vibracao nas rodas durante condução', 'Alinhamento e balanceamento realizados', 260.00),
(6, '2026-11-15 09:00:00', NULL, 'Em andamento', 'Problemas na suspensao dianteira', 'Aguardando substituicao de componentes', 480.00),
(7, '2026-11-16 08:00:00', '2026-11-16 10:30:00', 'Concluida', 'Ar condicionado com baixa refrigeracao', 'Sistema higienizado e revisado', 180.00),
(8, '2026-11-17 09:00:00', NULL, 'Aberta', 'Luz de advertencia acesa no painel', 'Aguardando inicio do diagnostico', 0.00);

-- ====================================
-- INSERT DAS ORDEM DAS PECAS
-- ====================================

INSERT INTO pecas_ordem (
    id_ordem, id_peca, quantidade, valor_unitario
)
VALUES
(1, 1, 1, 45.90),
(2, 3, 2, 125.00),
(3, 2, 1, 42.00),
(4, 5, 1, 98.00),
(5, 4, 2, 215.00),
(6, 6, 1, 345.00),
(7, 7, 4, 24.00),
(8, 8, 1, 435.00);

-- ========================================
-- INSERT DOS PAGAMENTOS
-- ========================================
 
INSERT INTO pagamentos (
    id_ordem, data_pagamento, valor, forma_pagamento, status, observacoes
)
VALUES
(1, '2026-11-10 10:05:00', 245.90, 'Pix', 'Confirmado', 'Pagamento integral da ordem'),
(2, '2026-11-11 12:10:00', 389.90, 'Cartao de credito', 'Confirmado', 'Pagamento aprovado'),
(3, '2026-11-12 11:00:00', 150.00, 'Pix', 'Confirmado', 'Primeira parte do pagamento'),
(3, '2026-11-12 11:15:00', 149.80, 'Dinheiro', 'Confirmado', 'Complemento do pagamento'),
(4, '2026-11-13 10:30:00', 150.00, 'Pix', 'Pendente', 'Pagamento aguardando confirmacao'),
(5, '2026-11-14 11:05:00', 260.00, 'Cartao de debito', 'Confirmado', 'Pagamento realizado na retirada'),
(6, '2026-11-15 09:30:00', 200.00, 'Pix', 'Pendente', 'Entrada referente ao servico'),
(7, '2026-11-16 10:40:00', 180.00, 'Dinheiro', 'Confirmado', 'Pagamento integral');

-- =====================================
-- INSERT DAS ORDENS DOS MECANICOS
-- =====================================

INSERT INTO ordem_mecanico (
    id_ordem,
    id_mecanico,
    data_alocacao,
    horas_trabalhadas,
    observacoes
)
VALUES
(1, 1, '2026-11-10 08:00:00', 2.00, 'Responsavel pela troca de oleo'),
(2, 3, '2026-11-11 09:00:00', 3.00, 'Responsavel pela revisao dos freios'),
(3, 2, '2026-11-12 08:30:00', 2.50, 'Responsavel pela revisao preventiva'),
(4, 5, '2026-11-13 10:00:00', 1.50, 'Diagnostico do sistema de injecao'),
(5, 4, '2026-11-14 08:00:00', 3.00, 'Responsavel pelo alinhamento'),
(6, 2, '2026-11-15 09:00:00', 2.00, 'Inspecao da suspensao dianteira'),
(7, 7, '2026-11-16 08:00:00', 2.50, 'Higienizacao do ar condicionado'),
(8, 8, '2026-11-17 09:00:00', 0.00, 'Aguardando inicio do diagnostico');

-- =============================================
-- INSERT DOS FORNECEDORES DE PECAS
-- =============================================

INSERT INTO fornecedor_peca (
    id_fornecedor,
    id_peca,
    preco_compra,
    prazo_entrega_dias
)
VALUES
(1, 1, 28.50, 2),
(2, 2, 42.00, 3),
(3, 3, 125.00, 2),
(4, 4, 215.00, 4),
(5, 5, 98.00, 3),
(6, 6, 345.00, 5),
(7, 7, 24.00, 1),
(8, 8, 435.00, 2);

-- ====================================================
-- INSERT DOS ITENS DE SERVICO
-- ===================================================

INSERT INTO itens_servico (
    id_ordem,
    id_servico,
    quantidade,
    valor_unitario
)
VALUES
(1, 1, 1, 80.00),
(2, 4, 1, 180.00),
(3, 5, 1, 150.00),
(4, 5, 1, 150.00),
(5, 2, 1, 100.00),
(6, 7, 1, 220.00),
(7, 8, 1, 130.00),
(8, 5, 1, 150.00);

-- ================================================
--  INSERT DAS MOVIMENTACOES DO ESTOQUE
-- ===============================================
INSERT INTO movimentacoes_estoque (
    id_peca,
    id_fornecedor,
    id_ordem,
    tipo_movimentacao,
    quantidade,
    data_movimentacao,
    motivo
)
VALUES
(1, 1, NULL, 'Entrada', 20, '2026-11-01 08:00:00', 'Compra de filtros de oleo'),
(2, 2, NULL, 'Entrada', 15, '2026-11-02 09:00:00', 'Reposicao de filtros de ar'),
(3, 3, 2, 'Saida', 2, '2026-11-11 10:00:00', 'Utilizacao em ordem de servico'),
(4, 4, 5, 'Saida', 2, '2026-11-14 09:30:00', 'Utilizacao em ordem de servico'),
(5, 5, NULL, 'Entrada', 10, '2026-11-05 10:00:00', 'Compra de correias dentadas'),
(6, 6, 6, 'Saida', 1, '2026-11-15 10:00:00', 'Substituicao de amortecedor'),
(7, 7, NULL, 'Entrada', 50, '2026-11-06 08:30:00', 'Compra de velas de ignicao'),
(8, 8, NULL, 'Ajuste', 2, '2026-11-07 11:00:00', 'Ajuste de inventario');

-- =======================
-- CONFERINDO OS DADOS DAS TABELAS
-- ============================

SELECT 'clientes' AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'mecanicos', COUNT(*) FROM mecanicos
UNION ALL
SELECT 'servicos', COUNT(*) FROM servicos
UNION ALL
SELECT 'pecas', COUNT(*) FROM pecas
UNION ALL
SELECT 'fornecedores', COUNT(*) FROM fornecedores
UNION ALL
SELECT 'veiculos' AS tabela, COUNT(*) AS total FROM veiculos
UNION ALL
SELECT 'agendamentos', COUNT(*) FROM agendamentos
UNION ALL
SELECT 'ordens_servico', COUNT(*) FROM ordens_servico
UNION ALL
SELECT 'pecas_ordem', COUNT(*) FROM pecas_ordem
UNION ALL
SELECT 'pagamentos', COUNT(*) FROM pagamentos
UNION ALL
SELECT 'ordem_mecanico', COUNT(*) FROM ordem_mecanico
UNION ALL
SELECT 'fornecedor_peca', COUNT(*) FROM fornecedor_peca
UNION ALL
SELECT 'itens_servico', COUNT(*) FROM itens_servico
UNION ALL
SELECT 'movimentacoes_estoque', COUNT(*) FROM movimentacoes_estoque;

-- ==================================
-- TESTANDO OS LIMITES DO BANCO
-- ==================================
INSERT INTO clientes (nome, cpf, telefone, email)
VALUES ('Cliente Teste', '10000000001', '98989999999', 'teste@email.com');

INSERT INTO servicos (
    descricao,
    detalhes,
    valor_mao_obra,
    tempo_estimado_min,
    ativo
)
VALUES (
    'Servico Teste',
    'Teste de restricao de valor negativo',
    -50.00,
    30,
    TRUE
);

INSERT INTO veiculos (
    id_cliente,
    placa,
    marca,
    modelo,
    ano,
    cor,
    quilometragem
)
VALUES (
    99999,
    'TEST999',
    'Fiat',
    'Uno',
    2015,
    'Branco',
    100000
);

-- ==============================================
-- COLOCANDO 10000 DADOS NO BANCO DE DADOS
-- ===============================================

INSERT INTO movimentacoes_estoque (
    id_peca,
    id_fornecedor,
    id_ordem,
    tipo_movimentacao,
    quantidade,
    data_movimentacao,
    motivo
)
WITH RECURSIVE numeros AS (
    SELECT 1 AS n

    UNION ALL

    SELECT n + 1
    FROM numeros
    WHERE n < 9992
)
SELECT
    MOD(n - 1, 8) + 1,
    MOD(n - 1, 8) + 1,
    CASE
        WHEN MOD(n, 3) = 0 THEN MOD(n - 1, 8) + 1
        ELSE NULL
    END,
    CASE
        WHEN MOD(n, 3) = 0 THEN 'Entrada'
        WHEN MOD(n, 3) = 1 THEN 'Saida'
        ELSE 'Ajuste'
    END,
    MOD(n, 10) + 1,
    DATE_ADD('2025-11-19 08:00:00', INTERVAL MOD(n, 365) DAY),
    CASE
        WHEN MOD(n, 3) = 0 THEN 'Reposicao de estoque'
        WHEN MOD(n, 3) = 1 THEN 'Utilizacao em servico'
        ELSE 'Ajuste de inventario'
    END
FROM numeros;
 
 -- =============================
 --  CONFERINDO OS 10000 DADOS GERADOS
 -- ===============================
 
SELECT COUNT(*) AS total_movimentacoes
FROM movimentacoes_estoque;

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

-- ================================
-- VIEW 01: Clientes e seus veículos
-- Objetivo: Relacionar clientes aos seus respectivos veículos.
-- ===============================

CREATE VIEW vw_clientes_veiculos AS
SELECT
    c.id_cliente,
    c.nome AS cliente,
    c.telefone,
    c.email,
    v.id_veiculo,
    v.placa,
    v.marca,
    v.modelo,
    v.ano,
    v.cor,
    v.quilometragem
FROM clientes c
INNER JOIN veiculos v
    ON c.id_cliente = v.id_cliente;

SELECT * FROM vw_clientes_veiculos;

-- ================================================
-- VIEW 02: Ordens de serviço detalhadas
-- Objetivo: Reunir dados das ordens, clientes e veículos.
-- =================================================

CREATE VIEW vw_ordens_servico_detalhadas AS
SELECT
    os.id_ordem,
    c.id_cliente,
    c.nome AS cliente,
    v.id_veiculo,
    v.placa,
    v.marca,
    v.modelo,
    v.ano,
    os.data_abertura,
    os.data_fechamento,
    os.status,
    os.descricao_problema,
    os.observacoes,
    os.valor_total
FROM ordens_servico os
INNER JOIN veiculos v
    ON os.id_veiculo = v.id_veiculo
INNER JOIN clientes c
    ON v.id_cliente = c.id_cliente;
    
SELECT * FROM vw_ordens_servico_detalhadas;

-- =====================================================
-- VIEW 03: Peças e fornecedores
-- Objetivo: Relacionar peças aos fornecedores, preços e prazos de entrega.
-- ========================================================

CREATE VIEW vw_pecas_fornecedores AS
SELECT
    p.id_peca,
    p.codigo,
    p.descricao AS peca,
    p.fabricante,
    f.id_fornecedor,
    f.razao_social AS fornecedor,
    fp.preco_compra,
    fp.prazo_entrega_dias
FROM fornecedor_peca fp
INNER JOIN pecas p
    ON fp.id_peca = p.id_peca
INNER JOIN fornecedores f
    ON fp.id_fornecedor = f.id_fornecedor;
    
SELECT * FROM vw_pecas_fornecedores;

-- =====================================
-- VERIFICANDO OS DAODS ANTES DE FAZER A ORDEM DE SERVIÇOS
-- =====================================
SELECT id_veiculo, placa, marca, modelo
FROM veiculos;

SELECT id_servico, descricao, valor_mao_obra
FROM servicos;

-- =========================================================
-- TRANSAÇÃO 01: Abertura de Ordem de Serviço
-- =========================================================

START TRANSACTION;

-- 1. Criar uma nova ordem de serviço
INSERT INTO ordens_servico (
    id_veiculo,
    descricao_problema,
    status,
    valor_total
)
VALUES (
    8,
    'Falha no funcionamento do sistema eletrônico do veículo',
    'Aberta',
    150.00
);

-- 2. Recuperar o ID da ordem recém-criada
SET @id_ordem_nova = LAST_INSERT_ID();

-- 3. Adicionar o serviço de diagnóstico eletrônico
INSERT INTO itens_servico (
    id_ordem,
    id_servico,
    quantidade,
    valor_unitario
)
VALUES (
    @id_ordem_nova,
    5,
    1,
    150.00
);

-- 4. Confirmar a transação
COMMIT;

SELECT * FROM ordens_servico
ORDER BY id_ordem DESC
LIMIT 1;

SELECT * FROM itens_servico
ORDER BY id_item_servico DESC
LIMIT 1;

-- =========================================================
-- TRANSAÇÃO 02: Registro de pagamento de ordem de serviço
-- =========================================================

START TRANSACTION;

-- 1. Recuperar a ordem de serviço criada anteriormente
SET @id_ordem_pagamento = (
    SELECT id_ordem
    FROM ordens_servico
    WHERE descricao_problema = 'Falha no funcionamento do sistema eletrônico do veículo'
    ORDER BY id_ordem DESC
    LIMIT 1
);

-- 2. Registrar o pagamento
INSERT INTO pagamentos (
    id_ordem,
    valor,
    forma_pagamento,
    status,
    observacoes
)
VALUES (
    @id_ordem_pagamento,
    150.00,
    'Pix',
    'Confirmado',
    'Pagamento integral do diagnóstico eletrônico'
);

-- 3. Atualizar a ordem de serviço
UPDATE ordens_servico
SET
    status = 'Concluida',
    data_fechamento = NOW()
WHERE id_ordem = @id_ordem_pagamento;

-- 4. Confirmar as operações
COMMIT;

SELECT * FROM pagamentos
ORDER BY id_pagamento DESC
LIMIT 1;

SELECT
    id_ordem,
    status,
    data_abertura,
    data_fechamento,
    valor_total
FROM ordens_servico
ORDER BY id_ordem DESC
LIMIT 1;

-- =========================================================
-- PROCEDURE 01: Cadastro de clientes
-- =========================================================

DELIMITER //

CREATE PROCEDURE sp_cadastrar_cliente(
    IN p_nome VARCHAR(100),
    IN p_cpf CHAR(11),
    IN p_telefone VARCHAR(20),
    IN p_email VARCHAR(120)
)
BEGIN
    INSERT INTO clientes (
        nome,
        cpf,
        telefone,
        email
    )
    VALUES (
        p_nome,
        p_cpf,
        p_telefone,
        p_email
    );
END //

DELIMITER ;

CALL sp_cadastrar_cliente(
    'Cliente Teste Procedure',
    '98765432100',
    '98999990000',
    'testeprocedure@email.com'
);

-- =========================================================
-- PROCEDURE 02: Abertura de ordem de serviço
-- =========================================================

DELIMITER //

CREATE PROCEDURE sp_abrir_ordem_servico(
    IN p_id_veiculo INT,
    IN p_descricao_problema VARCHAR(255),
    IN p_id_servico INT,
    IN p_quantidade INT
)
BEGIN
    DECLARE v_valor_servico DECIMAL(10,2);
    DECLARE v_id_ordem INT;
    DECLARE v_veiculo_existe INT DEFAULT 0;
    DECLARE v_servico_existe INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Verificar se o veículo existe
    SELECT COUNT(*)
    INTO v_veiculo_existe
    FROM veiculos
    WHERE id_veiculo = p_id_veiculo;

    IF v_veiculo_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Veiculo nao encontrado.';
    END IF;

    -- 2. Verificar se o serviço existe e está ativo
    SELECT COUNT(*)
    INTO v_servico_existe
    FROM servicos
    WHERE id_servico = p_id_servico
      AND ativo = TRUE;

    IF v_servico_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Servico inexistente ou inativo.';
    END IF;

    -- 3. Recuperar o valor da mão de obra
    SELECT valor_mao_obra
    INTO v_valor_servico
    FROM servicos
    WHERE id_servico = p_id_servico;

    -- 4. Criar a ordem de serviço
    INSERT INTO ordens_servico (
        id_veiculo,
        descricao_problema,
        status,
        valor_total
    )
    VALUES (
        p_id_veiculo,
        p_descricao_problema,
        'Aberta',
        v_valor_servico * p_quantidade
    );

    SET v_id_ordem = LAST_INSERT_ID();

    -- 5. Registrar o serviço na ordem
    INSERT INTO itens_servico (
        id_ordem,
        id_servico,
        quantidade,
        valor_unitario
    )
    VALUES (
        v_id_ordem,
        p_id_servico,
        p_quantidade,
        v_valor_servico
    );

    -- 6. Confirmar todas as operações
    COMMIT;

END //

DELIMITER ;

CALL sp_abrir_ordem_servico(
    7,
    'Manutencao preventiva com troca de oleo',
    1,
    1
);

SELECT * FROM ordens_servico
ORDER BY id_ordem DESC
LIMIT 1;

SELECT * FROM itens_servico
ORDER BY id_item_servico DESC
LIMIT 1;

SELECT
    id_ordem,
    descricao_problema,
    status,
    valor_total
FROM ordens_servico
ORDER BY id_ordem;

-- =========================================================
-- PROCEDURE 03: Registro de pagamento
-- =========================================================

DELIMITER //

CREATE PROCEDURE sp_registrar_pagamento(
    IN p_id_ordem INT,
    IN p_valor DECIMAL(10,2),
    IN p_forma_pagamento VARCHAR(50)
)
BEGIN
    DECLARE v_valor_ordem DECIMAL(10,2);
    DECLARE v_total_pago DECIMAL(10,2) DEFAULT 0;
    DECLARE v_ordem_existe INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Verificar se a ordem existe
    SELECT COUNT(*)
    INTO v_ordem_existe
    FROM ordens_servico
    WHERE id_ordem = p_id_ordem;

    IF v_ordem_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ordem de servico nao encontrada.';
    END IF;

    -- 2. Recuperar o valor total da ordem
    SELECT valor_total
    INTO v_valor_ordem
    FROM ordens_servico
    WHERE id_ordem = p_id_ordem;

    -- 3. Validar o valor do pagamento
    IF p_valor <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O valor do pagamento deve ser maior que zero.';
    END IF;

    -- 4. Registrar o pagamento
    INSERT INTO pagamentos (
        id_ordem,
        valor,
        forma_pagamento,
        status,
        observacoes
    )
    VALUES (
        p_id_ordem,
        p_valor,
        p_forma_pagamento,
        'Confirmado',
        'Pagamento registrado via procedure'
    );

    -- 5. Calcular o total de pagamentos confirmados
    SELECT COALESCE(SUM(valor), 0)
    INTO v_total_pago
    FROM pagamentos
    WHERE id_ordem = p_id_ordem
      AND status = 'Confirmado';

    -- 6. Se o total pago atingir o valor da ordem, concluir a OS
    IF v_total_pago >= v_valor_ordem THEN
        UPDATE ordens_servico
        SET
            status = 'Concluida',
            data_fechamento = COALESCE(data_fechamento, NOW())
        WHERE id_ordem = p_id_ordem;
    END IF;

    -- 7. Confirmar a transação
    COMMIT;

END //

DELIMITER ;

CALL sp_registrar_pagamento(
    10,
    80.00,
    'Pix'
);

SELECT * FROM pagamentos
WHERE id_ordem = 10;

SELECT
    id_ordem,
    status,
    valor_total,
    data_fechamento
FROM ordens_servico
WHERE id_ordem = 10;

-- =========================================================
-- FUNCTION 01: Total pago por ordem de serviço
-- =========================================================

DELIMITER //

CREATE FUNCTION fn_total_pago_ordem(
    p_id_ordem INT
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total_pago DECIMAL(10,2) DEFAULT 0;

    SELECT COALESCE(SUM(valor), 0)
    INTO v_total_pago
    FROM pagamentos
    WHERE id_ordem = p_id_ordem
      AND status = 'Confirmado';

    RETURN v_total_pago;
END //

DELIMITER ;

SELECT fn_total_pago_ordem(10) AS total_pago;

-- =========================================================
-- FUNCTION 02: Saldo pendente de ordem de serviço
-- =========================================================

DELIMITER //

CREATE FUNCTION fn_saldo_pendente_ordem(
    p_id_ordem INT
)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_valor_ordem DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_pago DECIMAL(10,2) DEFAULT 0;
    DECLARE v_saldo DECIMAL(10,2) DEFAULT 0;

    -- Recuperar o valor total da ordem
    SELECT COALESCE(valor_total, 0)
    INTO v_valor_ordem
    FROM ordens_servico
    WHERE id_ordem = p_id_ordem;

    -- Calcular os pagamentos confirmados
    SELECT COALESCE(SUM(valor), 0)
    INTO v_total_pago
    FROM pagamentos
    WHERE id_ordem = p_id_ordem
      AND status = 'Confirmado';

    -- Calcular o saldo pendente
    SET v_saldo = GREATEST(v_valor_ordem - v_total_pago, 0);

    RETURN v_saldo;
END //

DELIMITER ;

SELECT fn_saldo_pendente_ordem(10) AS saldo_pendente;

-- =========================================================
-- TRIGGER 01: Validação de pagamentos
-- =========================================================

DELIMITER //

CREATE TRIGGER trg_validar_pagamento_ordem
BEFORE INSERT ON pagamentos
FOR EACH ROW
BEGIN
    DECLARE v_valor_ordem DECIMAL(10,2);
    DECLARE v_total_pago DECIMAL(10,2) DEFAULT 0;

    -- Recuperar o valor total da ordem
    SELECT valor_total
    INTO v_valor_ordem
    FROM ordens_servico
    WHERE id_ordem = NEW.id_ordem;

    -- Calcular pagamentos já confirmados
    SELECT COALESCE(SUM(valor), 0)
    INTO v_total_pago
    FROM pagamentos
    WHERE id_ordem = NEW.id_ordem
      AND status = 'Confirmado';

    -- Impedir que o pagamento ultrapasse o valor da ordem
    IF NEW.status = 'Confirmado'
       AND (v_total_pago + NEW.valor) > v_valor_ordem THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pagamento bloqueado: valor excede o saldo da ordem de servico.';

    END IF;

END //

DELIMITER ;

SHOW TRIGGERS;

INSERT INTO pagamentos (
    id_ordem,
    valor,
    forma_pagamento,
    status,
    observacoes
)
VALUES (
    8,
    1.00,
    'Pix',
    'Confirmado',
    'Teste de bloqueio pelo trigger'
);

-- =========================================================
-- TRIGGER 02: Validação de movimentações de estoque
-- =========================================================

DELIMITER //

CREATE TRIGGER trg_validar_movimentacao_estoque
BEFORE INSERT ON movimentacoes_estoque
FOR EACH ROW
BEGIN

    -- Validar movimentação de saída
    IF NEW.tipo_movimentacao = 'Saida'
       AND NEW.id_ordem IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Saida de estoque deve estar vinculada a uma ordem de servico.';

    END IF;

    -- Validar movimentação de entrada
    IF NEW.tipo_movimentacao = 'Entrada'
       AND NEW.id_fornecedor IS NULL THEN

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Entrada de estoque deve estar vinculada a um fornecedor.';

    END IF;

END //

DELIMITER ;

SHOW TRIGGERS;

INSERT INTO movimentacoes_estoque (
    id_peca,
    id_fornecedor,
    id_ordem,
    tipo_movimentacao,
    quantidade,
    motivo
)
VALUES (
    1,
    NULL,
    NULL,
    'Saida',
    1,
    'Teste de validacao do trigger'
);

-- ==========================================================
--  CRIAÇÃO DE INDEX PARA O BANCO
-- ========================================================
SHOW INDEX FROM ordens_servico;

EXPLAIN
SELECT
    id_movimentacao,
    id_peca,
    id_ordem,
    quantidade,
    data_movimentacao,
    motivo
FROM movimentacoes_estoque
WHERE tipo_movimentacao = 'Saida'
ORDER BY data_movimentacao DESC;

CREATE INDEX idx_mov_tipo_data
ON movimentacoes_estoque (tipo_movimentacao, data_movimentacao);

EXPLAIN
SELECT
    id_movimentacao,
    id_peca,
    id_ordem,
    quantidade,
    data_movimentacao,
    motivo
FROM movimentacoes_estoque
WHERE tipo_movimentacao = 'Saida'
ORDER BY data_movimentacao DESC;

EXPLAIN
SELECT
    id_movimentacao,
    id_peca,
    tipo_movimentacao,
    quantidade,
    data_movimentacao,
    motivo
FROM movimentacoes_estoque
WHERE id_peca = 3
ORDER BY data_movimentacao DESC;

CREATE INDEX idx_mov_peca_data
ON movimentacoes_estoque (id_peca, data_movimentacao);

EXPLAIN
SELECT
    id_movimentacao,
    id_peca,
    tipo_movimentacao,
    quantidade,
    data_movimentacao,
    motivo
FROM movimentacoes_estoque
WHERE id_peca = 3
ORDER BY data_movimentacao DESC;

EXPLAIN
SELECT
    p.id_peca,
    p.descricao,
    me.tipo_movimentacao,
    SUM(me.quantidade) AS quantidade_total,
    COUNT(*) AS total_movimentacoes
FROM movimentacoes_estoque me
INNER JOIN pecas p
    ON me.id_peca = p.id_peca
WHERE me.data_movimentacao BETWEEN '2026-10-21' AND '2026-11-20'
GROUP BY
    p.id_peca,
    p.descricao,
    me.tipo_movimentacao
HAVING SUM(me.quantidade) > 0
ORDER BY quantidade_total DESC;

CREATE INDEX idx_mov_data_peca_tipo
ON movimentacoes_estoque (
    data_movimentacao,
    id_peca,
    tipo_movimentacao
);

EXPLAIN
SELECT
    p.id_peca,
    p.descricao,
    me.tipo_movimentacao,
    SUM(me.quantidade) AS quantidade_total,
    COUNT(*) AS total_movimentacoes
FROM movimentacoes_estoque me
INNER JOIN pecas p
    ON me.id_peca = p.id_peca
WHERE me.data_movimentacao BETWEEN '2026-10-21' AND '2026-11-20'
GROUP BY
    p.id_peca,
    p.descricao,
    me.tipo_movimentacao
HAVING SUM(me.quantidade) > 0
ORDER BY quantidade_total DESC;

SELECT
    TABLE_NAME AS tabela,
    INDEX_NAME AS indice,
    COLUMN_NAME AS coluna,
    NON_UNIQUE AS nao_unico,
    SEQ_IN_INDEX AS ordem_coluna
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'autogest'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

SELECT DATABASE();
SHOW DATABASES;

SELECT
    TABLE_NAME AS tabela,
    INDEX_NAME AS indice,
    COLUMN_NAME AS coluna,
    NON_UNIQUE AS nao_unico,
    SEQ_IN_INDEX AS ordem_coluna
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'oficina'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

CREATE INDEX idx_pag_status_data
ON pagamentos (status, data_pagamento);

CREATE INDEX idx_os_status_data
ON ordens_servico (status, data_abertura);

CREATE INDEX idx_ag_status_data
ON agendamentos (status, data_hora);

CREATE INDEX idx_item_servico_ordem
ON itens_servico (id_servico, id_ordem);

-- =========================================== 
-- CRIAÇÃO DE AUDITORIAS E LOG'S
-- =========================================
CREATE TABLE logs_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50) NOT NULL,
    operacao VARCHAR(10) NOT NULL,
    id_registro INT NOT NULL,
    descricao TEXT,
    data_evento DATETIME DEFAULT CURRENT_TIMESTAMP
);

SHOW TABLES;
DESCRIBE logs_auditoria;

DELIMITER $$

CREATE TRIGGER trg_auditoria_clientes_insert
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO logs_auditoria (
        tabela_afetada,
        operacao,
        id_registro,
        descricao
    )
    VALUES (
        'clientes',
        'INSERT',
        NEW.id_cliente,
        CONCAT('Novo cliente cadastrado: ', NEW.nome)
    );
END$$

DELIMITER ;

INSERT INTO clientes (nome, cpf, telefone, email)
VALUES ('Cliente Auditoria', '11122233344', '98999999999', 'auditoria@email.com');

SELECT * FROM logs_auditoria;

DELIMITER $$

CREATE TRIGGER trg_auditoria_clientes_update
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO logs_auditoria (
        tabela_afetada,
        operacao,
        id_registro,
        descricao
    )
    VALUES (
        'clientes',
        'UPDATE',
        NEW.id_cliente,
        CONCAT(
            'Cliente alterado. Nome anterior: ',
            OLD.nome,
            ' | Nome atual: ',
            NEW.nome
        )
    );
END$$

DELIMITER ;

UPDATE clientes
SET nome = 'Cliente Auditoria Atualizado'
WHERE id_cliente = 11;

SELECT * FROM logs_auditoria
ORDER BY id_log DESC;


DELIMITER $$

CREATE TRIGGER trg_auditoria_clientes_delete
AFTER DELETE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO logs_auditoria (
        tabela_afetada,
        operacao,
        id_registro,
        descricao
    )
    VALUES (
        'clientes',
        'DELETE',
        OLD.id_cliente,
        CONCAT(
            'Cliente excluido: ',
            OLD.nome
        )
    );
END$$

DELIMITER ;

DELETE FROM clientes
WHERE id_cliente = 11;

SELECT * FROM logs_auditoria
ORDER BY id_log DESC;

DELIMITER $$

CREATE TRIGGER trg_auditoria_ordens_insert
AFTER INSERT ON ordens_servico
FOR EACH ROW
BEGIN
    INSERT INTO logs_auditoria (
        tabela_afetada,
        operacao,
        id_registro,
        descricao
    )
    VALUES (
        'ordens_servico',
        'INSERT',
        NEW.id_ordem,
        CONCAT(
            'Nova ordem de servico criada. Status: ',
            NEW.status
        )
    );
END$$

DELIMITER ;

SHOW TRIGGERS
WHERE `Table` = 'ordens_servico';

SELECT * FROM logs_auditoria
ORDER BY id_log DESC;

SHOW CREATE PROCEDURE sp_abrir_ordem_servico;

SELECT * FROM logs_auditoria
ORDER BY id_log DESC;

SHOW CREATE PROCEDURE sp_abrir_ordem_servico;

SELECT
    PARAMETER_NAME,
    DATA_TYPE,
    PARAMETER_MODE
FROM information_schema.PARAMETERS
WHERE SPECIFIC_SCHEMA = 'OFICINA'
AND SPECIFIC_NAME = 'sp_abrir_ordem_servico'
ORDER BY ORDINAL_POSITION;

SELECT ROUTINE_DEFINITION
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'OFICINA'
AND ROUTINE_NAME = 'sp_abrir_ordem_servico';

SELECT * FROM veiculos;

SELECT * FROM servicos;

CALL sp_abrir_ordem_servico(
    1,
    'Problema apresentado pelo cliente',
    1,
    1
);

SELECT * FROM logs_auditoria
ORDER BY id_log DESC;

CREATE INDEX idx_logs_tabela_data
ON logs_auditoria (tabela_afetada, data_evento);

SHOW INDEX FROM logs_auditoria;

-- ============================================
-- SEGURANÇA DO BANCO DE DADOS
-- =============================================

SELECT 
    user,
    host
FROM mysql.user
ORDER BY user, host;

CREATE USER 'oficina_app'@'localhost'
IDENTIFIED BY 'Oficina@2026_DB';

SELECT user, host
FROM mysql.user
WHERE user = 'oficina_app';

CREATE ROLE 'role_oficina_app';

GRANT SELECT, INSERT, UPDATE, DELETE
ON oficina.*
TO 'role_oficina_app';

GRANT 'role_oficina_app'
TO 'oficina_app'@'localhost';

SET DEFAULT ROLE 'role_oficina_app'
TO 'oficina_app'@'localhost';

SHOW GRANTS FOR 'oficina_app'@'localhost';

SELECT
    DATABASE() AS nome_banco,
    USER() AS usuario_conexao,
    CURRENT_USER() AS usuario_autenticado;
