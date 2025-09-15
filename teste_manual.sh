#!/bin/bash

echo "=== MENU DE TESTES MANUAIS ==="
echo ""
echo "Escolha o tipo de teste:"
echo "1. Teste de expressões aritméticas"
echo "2. Teste de atribuições"
echo "3. Teste de operadores lógicos"
echo "4. Teste de comparações"
echo "5. Teste de print"
echo "6. Teste personalizado (você digita)"
echo "7. Mostrar exemplos válidos"
echo "0. Sair"
echo ""

while true; do
    read -p "Digite sua opção (0-7): " opcao
    
    case $opcao in
        1)
            echo "Testando: result = 10 + 5 * 2"
            echo "result = 10 + 5 * 2" | ./pylite
            echo ""
            ;;
        2)
            echo "Testando: x = 42"
            echo "x = 42" | ./pylite
            echo ""
            ;;
        3)
            echo "Testando: flag = True and False"
            echo "flag = True and False" | ./pylite
            echo ""
            ;;
        4)
            echo "Testando: check = x > y"
            echo "check = x > y" | ./pylite
            echo ""
            ;;
        5)
            echo "Testando: print(\"Hello World\")"
            echo 'print("Hello World")' | ./pylite
            echo ""
            ;;
        6)
            echo "Digite seu código Python (termine com Ctrl+D):"
            ./pylite
            echo ""
            ;;
        7)
            echo "=== EXEMPLOS QUE FUNCIONAM ==="
            echo "• x = 10"
            echo "• result = 5 + 3 * 2"
            echo "• flag = True or False"
            echo "• check = x >= y"
            echo "• print(\"texto\")"
            echo "• valor = (10 + 5) * 2"
            echo ""
            echo "=== EXEMPLOS QUE NÃO FUNCIONAM (ainda) ==="
            echo "• if x > 0: (precisa de blocos)"
            echo "• def funcao(): (precisa de blocos)"
            echo "• while x < 10: (precisa de blocos)"
            echo ""
            ;;
        0)
            echo "Saindo..."
            break
            ;;
        *)
            echo "Opção inválida! Digite 0-7"
            ;;
    esac
done
