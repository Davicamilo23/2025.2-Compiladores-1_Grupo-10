#!/bin/bash

echo "=== TESTE MANUAL COM EXEMPLOS ==="
echo ""

# Função para testar e mostrar resultado
testar() {
    local codigo="$1"
    local descricao="$2"
    
    echo "📝 $descricao"
    echo "   Código: $codigo"
    echo "   Resultado:"
    echo "$codigo" | ./pylite
    echo "   Status: $([[ $? -eq 0 ]] && echo "✅ SUCESSO" || echo "❌ ERRO")"
    echo ""
}

# Testes básicos
testar "x = 5" "Atribuição simples"
testar "result = 10 + 20" "Expressão aritmética"
testar "flag = True" "Valor booleano"
testar "check = x == y" "Comparação"
testar "value = (5 + 3) * 2" "Expressão com parênteses"
testar "print(\"Hello\")" "Comando print"
testar "z = x and y" "Operador lógico"

echo "=== PARA TESTAR MANUALMENTE ==="
echo ""
echo "💡 Comandos úteis:"
echo ""
echo "1. Teste rápido:"
echo "   echo \"seu_codigo_aqui\" | ./pylite"
echo ""
echo "2. Teste interativo:"
echo "   ./pylite"
echo "   (digite código e pressione Ctrl+D)"
echo ""
echo "3. Teste de arquivo:"
echo "   ./pylite < nome_do_arquivo.py"
echo ""
echo "4. Criar e testar arquivo:"
echo "   echo \"x = 10\" > meu_teste.py"
echo "   ./pylite < meu_teste.py"
echo ""
echo "5. Menu interativo:"
echo "   ./teste_manual.sh"
