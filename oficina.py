
import mysql.connector
from mysql.connector import Error

conexao = None
cursor = None

try:
    # Conexão com o banco de dados oficina
    conexao = mysql.connector.connect(
        host='localhost',
        database='oficina',
        user='oficina_app',
        password='Oficina@2026_DB',
        port=3306
    )

    if conexao.is_connected():
        print("Conectado ao MySQL!")

        cursor = conexao.cursor()

        # Exibe a versão do MySQL
        cursor.execute("SELECT VERSION()")
        versao = cursor.fetchone()

        print("Versão do MySQL:", versao[0])

        # Verifica o banco conectado
        cursor.execute("SELECT DATABASE()")
        banco = cursor.fetchone()

        print("Banco conectado:", banco[0])

        # Consulta os clientes cadastrados
        cursor.execute("""
            SELECT id_cliente, nome, cpf, telefone
            FROM clientes
        """)

        resultados = cursor.fetchall()

        print("\nCLIENTES CADASTRADOS:")

        for cliente in resultados:
            print(cliente)

except Error as e:
    print("Erro ao conectar ou executar comandos:", e)

finally:
    if cursor is not None:
        cursor.close()

    if conexao is not None and conexao.is_connected():
        conexao.close()
        print("\nConexão encerrada.")
