
from db import conectar


def cadastrar_cliente():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        nome = input("Nome: ")
        cpf = input("CPF: ")
        telefone = input("Telefone: ")
        email = input("E-mail: ")

        sql = """
        INSERT INTO clientes (nome, cpf, telefone, email)
        VALUES (%s, %s, %s, %s)
        """

        valores = (nome, cpf, telefone, email)

        try:
            cursor.execute(sql, valores)
            conexao.commit()
            print("Cliente cadastrado com sucesso!")

        except Exception as erro:
            conexao.rollback()
            print("Erro ao cadastrar cliente:", erro)

        finally:
            cursor.close()
            conexao.close()


def listar_clientes():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        try:
            cursor.execute("SELECT * FROM clientes")

            clientes = cursor.fetchall()

            if clientes:
                for cliente in clientes:
                    print(cliente)
            else:
                print("Nenhum cliente cadastrado.")

        except Exception as erro:
            print("Erro ao listar clientes:", erro)

        finally:
            cursor.close()
            conexao.close()


def atualizar_cliente():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        id_cliente = input("Digite o ID do cliente: ")
        telefone = input("Digite o novo telefone: ")

        sql = """
        UPDATE clientes
        SET telefone = %s
        WHERE id_cliente = %s
        """

        try:
            cursor.execute(sql, (telefone, id_cliente))
            conexao.commit()

            if cursor.rowcount > 0:
                print("Cliente atualizado com sucesso!")
            else:
                print("Cliente não encontrado.")

        except Exception as erro:
            conexao.rollback()
            print("Erro ao atualizar cliente:", erro)

        finally:
            cursor.close()
            conexao.close()


def excluir_cliente():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        id_cliente = input("Digite o ID do cliente: ")

        try:
            cursor.execute(
                "DELETE FROM clientes WHERE id_cliente = %s",
                (id_cliente,)
            )

            conexao.commit()

            if cursor.rowcount > 0:
                print("Cliente excluído com sucesso!")
            else:
                print("Cliente não encontrado.")

        except Exception as erro:
            conexao.rollback()
            print("Erro ao excluir cliente:", erro)
            print("Verifique se existem veículos vinculados a esse cliente.")

        finally:
            cursor.close()
            conexao.close()


def menu_clientes():
    while True:
        print("\n--- MENU CLIENTES ---")
        print("\n--- CLIENTES ---")
        print("1 - Cadastrar cliente")
        print("2 - Listar clientes")
        print("3 - Atualizar cliente")
        print("4 - Excluir cliente")

        print("\n0 - Sair")

        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            cadastrar_cliente()

        elif opcao == "2":
            listar_clientes()

        elif opcao == "3":
            atualizar_cliente()

        elif opcao == "4":
            excluir_cliente()
            
        elif opcao == "0":
            print("Sistema encerrado.")
            break

        else:
            print("Opção inválida. Tente novamente.")


if __name__ == "__main__":
    menu_clientes()