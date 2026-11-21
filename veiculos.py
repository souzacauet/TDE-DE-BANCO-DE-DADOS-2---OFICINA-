from db import conectar


def cadastrar_veiculo():
    conexao = conectar()
    if conexao:
        cursor = conexao.cursor()
        id_cliente = input("ID do cliente proprietário: ").strip()
        marca = input("Marca: ").strip()
        modelo = input("Modelo: ").strip()
        ano = input("Ano: ").strip()
        placa = input("Placa: ").strip().upper()

        try:
            sql = """
                INSERT INTO veiculos (id_cliente, marca, modelo, ano, placa)
                VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(sql, (id_cliente, marca, modelo, ano, placa))
            conexao.commit()
            print("Veículo cadastrado com sucesso!")
        except Exception as erro:
            conexao.rollback()
            print("Erro ao cadastrar veículo:", erro)
        finally:
            cursor.close()
            conexao.close()


def listar_veiculos():
    conexao = conectar()
    if conexao:
        cursor = conexao.cursor()
        try:
            cursor.execute(
                "SELECT id_veiculo, id_cliente, marca, modelo, ano, placa FROM veiculos"
            )
            veiculos = cursor.fetchall()

            if not veiculos:
                print("Nenhum veículo encontrado.")
            else:
                print("\n--- LISTA DE VEÍCULOS ---")
                for v in veiculos:
                    print(
                        f"ID: {v[0]} | Cliente ID: {v[1]} | "
                        f"{v[2]} {v[3]} ({v[4]}) | Placa: {v[5]}"
                    )
        except Exception as erro:
            print("Erro ao listar veículos:", erro)
        finally:
            cursor.close()
            conexao.close()


def atualizar_veiculo():
    conexao = conectar()
    if conexao:
        cursor = conexao.cursor()
        id_veiculo = input("Digite o ID do veículo a atualizar: ").strip()
        nova_placa = input("Nova placa: ").strip().upper()
        novo_modelo = input("Novo modelo: ").strip()

        try:
            sql = """
                UPDATE veiculos
                SET placa = %s, modelo = %s
                WHERE id_veiculo = %s
            """
            cursor.execute(sql, (nova_placa, novo_modelo, id_veiculo))
            conexao.commit()

            if cursor.rowcount > 0:
                print("Veículo atualizado com sucesso!")
            else:
                print("Nenhum veículo encontrado com esse ID.")
        except Exception as erro:
            conexao.rollback()
            print("Erro ao atualizar veículo:", erro)
        finally:
            cursor.close()
            conexao.close()


def excluir_veiculo():
    conexao = conectar()
    if conexao:
        cursor = conexao.cursor()
        id_veiculo = input("Digite o ID do veículo a excluir: ").strip()

        try:
            cursor.execute(
                "DELETE FROM veiculos WHERE id_veiculo = %s",
                (id_veiculo,),
            )
            conexao.commit()

            if cursor.rowcount > 0:
                print("Veículo excluído com sucesso!")
            else:
                print("Nenhum veículo encontrado com esse ID.")
        except Exception as erro:
            conexao.rollback()
            print("Erro ao excluir veículo:", erro)
        finally:
            cursor.close()
            conexao.close()


def menu_veiculos():
    while True:
        print("\n--- MENU VEÍCULOS ---")
        print("1 - Cadastrar veículo")
        print("2 - Listar veículos")
        print("3 - Atualizar veículo")
        print("4 - Excluir veículo")
        print("0 - Voltar")
        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            cadastrar_veiculo()
        elif opcao == "2":
            listar_veiculos()
        elif opcao == "3":
            atualizar_veiculo()
        elif opcao == "4":
            excluir_veiculo()
        elif opcao == "0":
            break
        else:
            print("Opção inválida. Tente novamente.")


if __name__ == "__main__":
    menu_veiculos()