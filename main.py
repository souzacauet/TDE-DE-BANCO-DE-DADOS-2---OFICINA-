
from clientes import menu_clientes
from veiculos import menu_veiculos
from ordem_servico import menu_ordens


def main():
    while True:
        print("\n========== SISTEMA OFICINA ==========")
        print("1 - Gerenciar clientes")
        print("2 - Gerenciar veículos")
        print("3 - Gerenciar ordens de serviço")
        print("0 - Sair")
        print("=====================================")

        opcao = input("Escolha uma opção: ").strip()

        if opcao == "1":
            menu_clientes()

        elif opcao == "2":
            menu_veiculos()

        elif opcao == "3":
            menu_ordens()

        elif opcao == "0":
            print("Encerrando o sistema...")
            break

        else:
            print("Opção inválida. Tente novamente.")


if __name__ == "__main__":
    main()
