import os
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error

load_dotenv()


def conectar():
    try:
        conexao = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=int(os.getenv("DB_PORT", "3306")),
            database=os.getenv("DB_NAME", "oficina"),
            user=os.getenv("DB_USER", "oficina_app"),
            password=os.getenv("DB_PASSWORD"),
        )
        if conexao.is_connected():
            return conexao
    except Error as erro:
        print("Erro na conexão:", erro)
    return None