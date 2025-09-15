#!/bin/bash

echo "=== TESTE DE CASOS DE ERRO ==="
echo ""

echo "1. Teste erro de sintaxe - operador inválido:"
echo "   Conteúdo: x = 5 @@ 2"
echo "x = 5 @@ 2" | ./pylite
echo ""

echo "2. Teste erro de sintaxe - parênteses não fechados:"
echo "   Conteúdo: result = (5 + 3"
echo "result = (5 + 3" | ./pylite
echo ""

echo "3. Teste expressão válida com parênteses:"
echo "   Conteúdo: result = (5 + 3) * 2"
echo "result = (5 + 3) * 2" | ./pylite
echo ""

echo "4. Teste tokens válidos:"
echo "   Conteúdo: x = True and False"
echo "x = True and False" | ./pylite
echo ""

echo "=== FIM DOS TESTES DE ERRO ==="
