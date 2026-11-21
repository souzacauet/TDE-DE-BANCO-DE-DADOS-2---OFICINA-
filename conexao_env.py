import os
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

load_dotenv()

conexao = None
cursor = None

try:

    host = os.getenv("DB_HOST", "localhost")
    port = int(os.getenv("DB_PORT", "3306"))  
    database = os.getenv("DB_NAME", "oficina")
    user = os.getenv("DB_USER", "oficina_app")
    password = os.getenv("DB_PASSWORD")

    if not password:
        raise ValueError("A variável DB_PASSWORD não foi definida no ficheiro .env.")

    conexao = mysql.connector.connect(
        host=host,
        port=port,
        database=database,
        user=user,
        password=password,
    )

    if conexao.is_connected():
        print("Conectado ao MySQL com sucesso!")
        cursor = conexao.cursor()
        cursor.execute("SELECT DATABASE(), USER();")
        print("Detalhes da sessão:", cursor.fetchone())

except Error as erro:
    print(f"Erro do MySQL: {erro}")
except ValueError as erro_config:
    print(f"Erro de configuração: {erro_config}")
finally:

    if cursor:
        cursor.close()
    if conexao and conexao.is_connected():
        conexao.close()
        print("Conexão encerrada.")