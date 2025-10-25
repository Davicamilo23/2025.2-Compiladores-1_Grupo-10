#!/bin/bash

# Script para executar testes de tipagem de variáveis
# Autor: Sistema de Compilação
# Data: 2025

echo "=========================================="
echo "   TESTES DE TIPAGEM DE VARIÁVEIS"
echo "=========================================="
echo ""

# Define cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de testes
TOTAL=0
PASSED=0
FAILED=0

# Diretório dos testes
TEST_DIR="tests/tipos"
PARSER="./parser"

# Verifica se o parser existe
if [ ! -f "$PARSER" ]; then
    echo -e "${RED}[ERRO]${NC} Parser não encontrado. Execute 'make' primeiro."
    exit 1
fi

echo "Diretório de testes: $TEST_DIR"
echo "Parser: $PARSER"
echo ""

# Função para executar um teste
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .c)
    local expected_result=$2  # "pass" ou "fail"
    
    TOTAL=$((TOTAL + 1))
    
    echo -n "[$TOTAL] Testando: $test_name ... "
    
    # Executa o parser e captura a saída
    output=$($PARSER < "$test_file" 2>&1)
    exit_code=$?
    
    # Verifica se há erros semânticos na saída
    if echo "$output" | grep -q "Erro semântico"; then
        result="fail"
    else
        result="pass"
    fi
    
    # Compara com o resultado esperado
    if [ "$result" == "$expected_result" ]; then
        echo -e "${GREEN}[OK]${NC}"
        PASSED=$((PASSED + 1))
        
        # Mostra warnings se houver
        if echo "$output" | grep -q "Aviso"; then
            echo "$output" | grep "Aviso" | sed 's/^/    /'
        fi
    else
        echo -e "${RED}[FALHOU]${NC}"
        FAILED=$((FAILED + 1))
        echo "    Esperado: $expected_result, Obtido: $result"
        echo "    Saída do parser:"
        echo "$output" | sed 's/^/    /'
    fi
    echo ""
}

# Testes que devem passar (sem erros semânticos)
echo "=== TESTES QUE DEVEM PASSAR ==="
echo ""

run_test "$TEST_DIR/test_declaracoes_validas.c" "pass"
run_test "$TEST_DIR/test_declaracoes_com_init.c" "pass"
run_test "$TEST_DIR/test_operacoes_aritmeticas.c" "pass"
run_test "$TEST_DIR/test_arrays.c" "pass"
run_test "$TEST_DIR/test_ponteiros.c" "pass"
run_test "$TEST_DIR/test_modulo_int.c" "pass"

# Testes que devem falhar (com erros semânticos)
echo "=== TESTES QUE DEVEM FALHAR ==="
echo ""

run_test "$TEST_DIR/test_erro_redeclaracao.c" "fail"
run_test "$TEST_DIR/test_erro_nao_declarada.c" "fail"
run_test "$TEST_DIR/test_erro_tipo_incompativel.c" "fail"
run_test "$TEST_DIR/test_erro_modulo_float.c" "fail"

# Resumo
echo ""
echo "=========================================="
echo "              RESUMO DOS TESTES"
echo "=========================================="
echo "Total de testes: $TOTAL"
echo -e "${GREEN}Testes passados: $PASSED${NC}"
echo -e "${RED}Testes falhados: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}Todos os testes passaram! ✓${NC}"
    exit 0
else
    echo -e "${RED}Alguns testes falharam. ✗${NC}"
    exit 1
fi
