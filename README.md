# TDE-DE-BANCO-DE-DADOS-2---OFICINA-
Entrega do segundo TDE de Banco de Dados - Oficina Mecânica.

# Sistema de Gestão de Oficina Mecânica — Oficina

Entrega do segundo TDE da disciplina de **Banco de Dados com Backend em Python** (Prof. Dr. Thiago Nelson Faria dos Reis).

O projeto consiste em uma solução completa para o gerenciamento operacional e financeiro de uma oficina mecânica, integrando um banco de dados relacional em **MySQL 8.0+** (modelado na 3ª Forma Normal com triggers, auditoria, stored procedures, functions, views e índices otimizados) a uma aplicação backend em **Python**.

---

## Índice

- [Sobre o Projeto]
- [Estrutura do Repositório]
- [Modelagem e Recursos do Banco de Dados]
- [Pré-requisitos]
- [Instalação e Configuração]
- [Como Executar]
- [Segurança e Controle de Acesso]
- [Equipe]

---

## Sobre o Projeto

O sistema de OFICINA foi projetado para controlar o fluxo operacional de uma oficina mecânica, abrangendo desde o cadastro de clientes e veículos até a abertura e acompanhamento de ordens de serviço, alocação de mecânicos, movimentação de estoque de peças, pagamentos e auditoria automática de alterações.

### Funcionalidades Principais

- **Gestão de Cadastros (CRUD):** Controle de clientes, veículos, mecânicos, serviços, peças e fornecedores.
- **Ordens de Serviço (OS):** Abertura, vinculação de serviços e peças com cálculo automático de subtotais, alocação de mecânicos e controle de status (`Aberta`, `Em andamento`, `Concluida`).
- **Controle Financeiro:** Registro de pagamentos parciais ou integrais, cálculo de saldo pendente e bloqueio automático contra pagamentos acima do valor da OS.
- **Controle de Estoque:** Registro de entradas (vinculadas a fornecedores), saídas (vinculadas a ordens de serviço) e ajustes de inventário.
- **Auditoria e Logs:** Rastreamento automático de operações (`INSERT`, `UPDATE`, `DELETE`) nas tabelas críticas por meio de gatilhos (*triggers*).

---

## Estrutura do Repositório

Todos os scripts SQL, arquivos de configuração e módulos Python estão organizados na raiz do repositório:

TDE-DE-BANCO-DE-DADOS-2---OFICINA-/
├── README.md              # Documentação principal do projeto
├── TDE.BCA.sql            # Script completo: DDL, carga inicial, 10.000 movimentações, rotinas, triggers, índices e segurança
├── 07_consultas.sql       # Consultas analíticas, relatórios e testes de desempenho (EXPLAIN)
├── .env.example           # Modelo de variáveis de ambiente para conexão com o banco
├── .env                   # Arquivo local de configuração de ambiente
├── requirements.txt       # Dependências Python do projeto (mysql-connector-python, python-dotenv)
├── db.py                  # Gerenciamento principal da conexão com o MySQL
├── conexao_bc.py          # Módulo auxiliar de conexão com o banco de dados
├── conexao_env.py         # Carregamento e leitura das variáveis de ambiente (.env)
├── clientes.py            # Módulo CRUD de Clientes
├── veiculos.py            # Módulo CRUD de Veículos
├── ordem_servico.py       # Módulo CRUD e regras de negócio de Ordens de Serviço
├── oficina.py             # Regras gerais e menus operacionais da oficina
└── main.py                # Ponto de entrada da aplicação (CLI)

## Siga esses codigos para fazer a instalação do banco de dados no codespace
1. sudo apt-get update && sudo apt-get install -y mysql-server

2. sudo service mysql start

3. sudo service mysql status

4. pip install mysql-connector-python python-dotenv

5. sudo mysql -e "CREATE DATABASE IF NOT EXISTS oficina; CREATE USER IF NOT EXISTS 'oficina_app'@'localhost' IDENTIFIED BY 'Oficina@2026_DB'; GRANT ALL PRIVILEGES ON oficina.* TO 'oficina_app'@'localhost'; FLUSH PRIVILEGES;"

6. grep -vi "create database" ./TDE.BCA.sql > ./TDE_limpo.sql

7. sudo mysql oficina < ./TDE_limpo.sql

8. sudo mysql oficina -e "SHOW TABLES;"

9. python -c "from db import conectar; c = conectar(); print('OK:', bool(c)); c and c.close()"

10. python main.py
11. sudo mysql oficina -e "SHOW TABLES;"
