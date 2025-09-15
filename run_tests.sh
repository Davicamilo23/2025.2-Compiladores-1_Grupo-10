#!/bin/bash

echo "=== TESTE DO COMPILADOR PYLITE ==="
echo ""

echo "1. Teste básico de expressões:"
echo "   Arquivo: test_simple.py"
cat tests/test_simple.py
echo "   Resultado:"
./pylite < tests/test_simple.py
echo ""

echo "2. Teste de print:"
echo "   Arquivo: test_print.py"
cat tests/test_print.py
echo "   Resultado:"
./pylite < tests/test_print.py
echo ""

echo "3. Teste de expressões numéricas:"
echo "   Conteúdo: a = 10 + 5 * 2"
echo "a = 10 + 5 * 2" | ./pylite
echo ""

echo "4. Teste de comparação:"
echo "   Conteúdo: result = x > y"
echo "result = x > y" | ./pylite
echo ""

echo "=== FIM DOS TESTES ==="
