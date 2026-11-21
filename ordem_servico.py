
from db import conectar


def cadastrar_ordem():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        id_veiculo = input("ID do veículo: ")
        descricao = input("Descrição do problema: ")
        observacoes = input("Observações: ")

        sql = """
        INSERT INTO ordens_servico
        (id_veiculo, descricao_problema, observacoes)
        VALUES (%s, %s, %s)
        """

        valores = (id_veiculo, descricao, observacoes)

        try:
            cursor.execute(sql, valores)
            conexao.commit()
            print("Ordem de serviço cadastrada com sucesso!")

        except Exception as erro:
            conexao.rollback()
            print("Erro ao cadastrar ordem:", erro)

        finally:
            cursor.close()
            conexao.close()


def listar_ordens():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        try:
            sql = """
            SELECT
                os.id_ordem,
                c.nome,
                v.placa,
                v.modelo,
                os.data_abertura,
                os.status,
                os.descricao_problema,
                os.valor_total
            FROM ordens_servico os
            INNER JOIN veiculos v
                ON os.id_veiculo = v.id_veiculo
            INNER JOIN clientes c
                ON v.id_cliente = c.id_cliente
            ORDER BY os.id_ordem
            """

            cursor.execute(sql)
            ordens = cursor.fetchall()

            if ordens:
                for ordem in ordens:
                    print(ordem)
            else:
                print("Nenhuma ordem de serviço cadastrada.")

        except Exception as erro:
            print("Erro ao listar ordens:", erro)

        finally:
            cursor.close()
            conexao.close()


def atualizar_ordem():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        id_ordem = input("Digite o ID da ordem de serviço: ")

        print("\nStatus disponíveis:")
        print("1 - Aberta")
        print("2 - Em andamento")
        print("3 - Concluida")

        opcao = input("Escolha o novo status: ").strip()

        status_opcoes = {
            "1": "Aberta",
            "2": "Em andamento",
            "3": "Concluida"
        }

        if opcao not in status_opcoes:
            print("Opção de status inválida.")
            cursor.close()
            conexao.close()
            return

        status = status_opcoes[opcao]

        sql = """
        UPDATE ordens_servico
        SET status = %s,
            data_fechamento = CASE
                WHEN %s = 'Concluida' THEN CURRENT_TIMESTAMP
                ELSE NULL
            END
        WHERE id_ordem = %s
        """

        try:
            cursor.execute(sql, (status, status, id_ordem))
            conexao.commit()

            if cursor.rowcount > 0:
                print("Ordem de serviço atualizada com sucesso!")
            else:
                print("Ordem de serviço não encontrada.")

        except Exception as erro:
            conexao.rollback()
            print("Erro ao atualizar ordem:", erro)

        finally:
            cursor.close()
            conexao.close()


def excluir_ordem():
    conexao = conectar()

    if conexao:
        cursor = conexao.cursor()

        id_ordem = input("Digite o ID da ordem de serviço: ")

        try:
            cursor.execute(
                "DELETE FROM ordens_servico WHERE id_ordem = %s",
                (id_ordem,)
            )

            conexao.commit()

            if cursor.rowcount > 0:
                print("Ordem de serviço excluída com sucesso!")
            else:
                print("Ordem de serviço não encontrada.")

        except Exception as erro:
            conexao.rollback()
            print("Erro ao excluir ordem:", erro)
            print("Verifique se existem pagamentos, peças, serviços ou outros registros vinculados.")

        finally:
            cursor.close()
            conexao.close()


def menu_ordens():
    while True:
        print("\n===== MENU ORDENS DE SERVIÇO =====")
        print("1 - Cadastrar ordem de serviço")
        print("2 - Listar ordens de serviço")
        print("3 - Atualizar ordem de serviço")
        print("4 - Excluir ordem de serviço")
        print("0 - Voltar")

        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            cadastrar_ordem()

        elif opcao == "2":
            listar_ordens()

        elif opcao == "3":
            atualizar_ordem()

        elif opcao == "4":
            excluir_ordem()

        elif opcao == "0":
            break

        else:
            print("Opção inválida. Tente novamente.")


if __name__ == "__main__":
    menu_ordens()
