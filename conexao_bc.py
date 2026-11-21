import mysql.connector
from mysql.connector import Error


def conectar():
    try:
        conexao = mysql.connector.connect(
            host="localhost",
            database="oficina",
            user="oficina_app",
            password="Oficina@2026_DB",
            port=3306,
        )
        if conexao.is_connected():
            print("Conectado ao banco oficina!")
            return conexao
    except Error as erro:
        print("Erro na conexão:", erro)
    return None


if __name__ == "__main__":
    conn = conectar()
    if conn and conn.is_connected():
        conn.close()
        print("Conexão encerrada.")