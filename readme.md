# 🔧 Sistema de Gestão de Oficina Mecânica (`oficina`)

Projeto Integrador da disciplina de **Banco de Dados com Backend em Python** (Prof. Dr. Thiago Nelson Faria dos Reis).  
O sistema consiste em uma solução completa para gerenciamento de uma oficina mecânica, integrando um banco de dados relacional robusto em **MySQL 8.0+** (com regras de negócio, triggers, auditoria, procedures, functions, views e índices otimizados) a uma aplicação backend em **Python**.

---

## 📋 Índice

- [Sobre o Projeto](#-sobre-o-projeto)
- [Arquitetura e Estrutura do Repositório](#-arquitetura-e-estrutura-do-repositório)
- [Modelagem e Recursos do Banco de Dados](#-modelagem-e-recursos-do-banco-de-dados)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação e Configuração](#-instalação-e-configuração)
- [Como Executar](#-como-executar)
- [Segurança e Controle de Acesso](#-segurança-e-controle-de-acesso)
- [Equipe](#-equipe)

---

## 🎯 Sobre o Projeto

O sistema foi projetado para controlar todo o fluxo operacional de uma oficina mecânica, desde o cadastro de clientes e veículos até a execução de ordens de serviço, alocação de mecânicos, controle de movimentação de estoque de peças, fornecedores, pagamentos e auditoria de dados.

### Funcionalidades Principais
- **Gestão de Cadastros (CRUD):** Clientes, veículos, mecânicos, serviços, peças e fornecedores.
- **Ordens de Serviço (OS):** Abertura, vinculação de serviços e peças com cálculo automático de subtotais, alocação de mecânicos e acompanhamento de status (`Aberta`, `Em andamento`, `Concluida`).
- **Controle Financeiro:** Registro de pagamentos parciais ou integrais, cálculo de saldo pendente e bloqueio automático de pagamentos excedentes.
- **Controle de Estoque:** Registro de entradas (vinculadas a fornecedores), saídas (vinculadas a ordens de serviço) e ajustes de inventário.
- **Auditoria e Logs:** Rastreamento automático de inserções, atualizações e exclusões nas tabelas críticas.

---

## 📁 Arquitetura e Estrutura do Repositório

A estrutura do projeto organiza os scripts SQL, a documentação e os módulos do backend em Python:

```text
projeto-oficina/
├── README.md                    # Documentação principal do projeto
├── TDE.BCA.sql                  # Script completo de criação, carga, rotinas, triggers, índices e segurança
├── docs/                        # Documentação técnica e modelagem
│   ├── DER.png                  # Diagrama Entidade-Relacionamento
│   ├── dicionario_dados.md      # Descrição das tabelas, colunas e restrições
│   └── otimizacao.md            # Análise de performance (EXPLAIN antes/depois dos índices)
└── backend_oficina/             # Aplicação Backend em Python
    ├── .env.example             # Modelo de variáveis de ambiente (sem credenciais reais)
    ├── requirements.txt         # Dependências do projeto (mysql-connector-python, python-dotenv)
    ├── db.py                    # Gerenciamento da conexão com o MySQL
    ├── conexao_bc.py            # Módulo auxiliar de conexão com o banco
    ├── conexao_env.py           # Carregamento de variáveis de ambiente
    ├── clientes.py              # Operações CRUD de Clientes
    ├── veiculos.py              # Operações CRUD de Veículos
    ├── ordem_servico.py         # Operações CRUD e regras de Ordens de Serviço
    ├── oficina.py               # Regras gerais e menus da oficina
    └── main.py                  # Ponto de entrada da aplicação (CLI)
```

---

## 🗄️ Modelagem e Recursos do Banco de Dados

O banco de dados `oficina` foi modelado na **3ª Forma Normal (3FN)** utilizando a engine **InnoDB** e conta com **15 tabelas** (14 tabelas de domínio/associativas + 1 tabela de auditoria):

### Tabelas Implementadas
1. `clientes`: Dados cadastrais dos clientes (`CPF` único).
2. `veiculos`: Veículos vinculados aos clientes (`placa` única, validação de ano e quilometragem).
3. `mecanicos`: Profissionais da oficina e suas especialidades.
4. `servicos`: Catálogo de serviços, tempo estimado e valor de mão de obra.
5. `pecas`: Catálogo de peças, fabricante, custo médio e preço de venda.
6. `fornecedores`: Empresas fornecedoras de peças (`CNPJ` único).
7. `agendamentos`: Agendamento prévio de atendimentos para veículos.
8. `ordens_servico`: Cabeçalho das ordens de serviço, status, datas e valor total.
9. `itens_servico`: Tabela associativa entre OS e Serviços (com coluna gerada `subtotal`).
10. `pecas_ordem`: Tabela associativa entre OS e Peças (com coluna gerada `subtotal`).
11. `ordem_mecanico`: Tabela associativa N:N entre OS e Mecânicos (horas trabalhadas e data de alocação).
12. `fornecedor_peca`: Tabela associativa N:N entre Fornecedores e Peças (preço de compra e prazo de entrega).
13. `pagamentos`: Registro financeiro vinculado às ordens de serviço.
14. `movimentacoes_estoque`: Histórico de entradas, saídas e ajustes de peças (populada com **10.000 registros** via CTE recursiva para testes de carga e performance).
15. `logs_auditoria`: Registro automático de eventos de auditoria (`INSERT`, `UPDATE`, `DELETE`).

### Recursos Avançados de SQL (`TDE.BCA.sql`)
- **Integridade:** Chaves primárias, chaves estrangeiras (`ON UPDATE CASCADE`, `ON DELETE RESTRICT`), restrições `CHECK`, `UNIQUE`, `NOT NULL` e valores `DEFAULT`.
- **Views (3):** `vw_clientes_veiculos`, `vw_ordens_servico_detalhadas` e `vw_pecas_fornecedores`.
- **Stored Procedures (3):**
  - `sp_cadastrar_cliente`: Cadastro padronizado de clientes.
  - `sp_abrir_ordem_servico`: Transação atômica que valida veículo/serviço, abre a OS e insere o item de serviço.
  - `sp_registrar_pagamento`: Transação que registra o pagamento e conclui automaticamente a OS caso o valor total seja quitado.
- **Functions (2):**
  - `fn_total_pago_ordem(id_ordem)`: Retorna o somatório de pagamentos confirmados de uma OS.
  - `fn_saldo_pendente_ordem(id_ordem)`: Calcula o saldo restante a pagar de uma OS.
- **Triggers (6):**
  - Validação de regra de negócio: `trg_validar_pagamento_ordem` (impede pagamentos acima do valor da OS) e `trg_validar_movimentacao_estoque` (exige OS na saída e fornecedor na entrada).
  - Auditoria: `trg_auditoria_clientes_insert`, `trg_auditoria_clientes_update`, `trg_auditoria_clientes_delete` e `trg_auditoria_ordens_insert`.
- **Otimização e Índices:** Criação de índices compostos estratégicos (`idx_mov_tipo_data`, `idx_mov_peca_data`, `idx_mov_data_peca_tipo`, `idx_pag_status_data`, `idx_os_status_data`, `idx_ag_status_data`, `idx_item_servico_ordem`, `idx_logs_tabela_data`) validados com `EXPLAIN`.

---

## ⚙️ Pré-requisitos

Certifique-se de ter instalado em sua máquina:
- **MySQL Server 8.0** ou superior
- **Python 3.10** ou superior
- **Git**

---

## 🚀 Instalação e Configuração

### 1. Clonar o repositório
```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```

### 2. Criar e popular o Banco de Dados
Acesse o seu cliente MySQL (MySQL Workbench, DBeaver ou terminal) com um usuário administrador e execute o script SQL completo do projeto:
```bash
mysql -u root -p < TDE.BCA.sql
```
> **Nota:** O script `TDE.BCA.sql` cria o banco `oficina`, todas as tabelas, insere os dados iniciais, gera 10.000 movimentações de estoque, cria views, procedures, functions, triggers, índices e configura o usuário de aplicação. *(Observação: o script contém propositalmente 3 blocos na seção "TESTANDO OS LIMITES DO BANCO" e testes de triggers que geram erros esperados de validação).*

### 3. Configurar o Backend em Python
Acesse a pasta do backend, crie um ambiente virtual e instale as dependências:

```bash
cd backend_oficina

# Criar ambiente virtual
python -m venv venv

# Ativar ambiente virtual (Windows)
venv\Scripts\activate

# Ativar ambiente virtual (Linux/macOS)
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt
```

### 4. Configurar as Variáveis de Ambiente (`.env`)
Copie o arquivo `.env.example` para `.env` e preencha com as credenciais do usuário da aplicação criadas pelo script SQL:

```bash
cp .env.example .env
```

Exemplo de conteúdo do arquivo `.env`:
```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=oficina
DB_USER=oficina_app
DB_PASSWORD=Oficina@2026_DB
```

---

## ▶️ Como Executar

Com o ambiente virtual ativado e o arquivo `.env` configurado, inicie a aplicação pelo arquivo principal:

```bash
python main.py
```

Utilize o menu interativo no terminal para navegar entre os módulos de **Clientes**, **Veículos** e **Ordens de Serviço**.

---

## 🔒 Segurança e Controle de Acesso

Seguindo o princípio do menor privilégio, a aplicação Python **não utiliza o usuário `root`**. O script SQL cria uma role e um usuário dedicado para o backend:

- **Usuário da Aplicação:** `'oficina_app'@'localhost'`
- **Role:** `'role_oficina_app'`
- **Permissões:** `SELECT`, `INSERT`, `UPDATE`, `DELETE` (e `EXECUTE` nas rotinas) restritas exclusivamente ao schema `oficina.*`.

---

## 👥 Equipe

| Nome | Matrícula | E-mail | GitHub |
| :--- | :--- | :--- | :--- |
| Integrante 1 | `0000000` | integrante1@email.com | [@usuario1](https://github.com/) |
| Integrante 2 | `0000000` | integrante2@email.com | [@usuario2](https://github.com/) |
| Integrante 3 | `0000000` | integrante3@email.com | [@usuario3](https://github.com/) |
| Integrante 4 | `0000000` | integrante4@email.com | [@usuario4](https://github.com/) |
| Integrante 5 | `0000000` | integrante5@email.com | [@usuario5](https://github.com/) |

---
*Desenvolvido para a disciplina de Banco de Dados — 2026.*