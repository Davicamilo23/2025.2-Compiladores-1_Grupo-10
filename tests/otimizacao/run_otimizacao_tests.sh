# teste criado para verificar otimização
echo "=========================================="
echo "   TESTES DE OTIMIZAÇÃO - PROPAGAÇÃO"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 

# Diretório dos testes
TEST_DIR="tests/otimizacao"
COMPILADOR="./c2python"

# Verifica se o compilador existe
if [ ! -f "$COMPILADOR" ]; then
    echo -e "${RED}[ERRO]${NC} Compilador não encontrado. Execute 'make' primeiro."
    exit 1
fi

echo "Diretório de testes: $TEST_DIR"
echo "Compilador: $COMPILADOR"
echo ""

# Função para executar um teste
run_test() {
    local test_file=$1
    local test_name=$(basename "$test_file" .c)
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Teste: $test_name${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Executa o compilador e captura a saída
    echo "Código fonte:"
    cat "$test_file" | grep -v "^//" | grep -v "^$"
    echo ""
    
    echo "Saída do compilador:"
    $COMPILADOR < "$test_file" 2>&1 | grep -E "\[OPT\]|Constant folding|Propagada|ESTATÍSTICAS"
    
    echo ""
    echo ""
}

# Executar todos os testes
echo -e "${GREEN}=== EXECUTANDO TESTES DE OTIMIZAÇÃO ===${NC}"
echo ""

run_test "$TEST_DIR/test_propagacao_simples.c"
run_test "$TEST_DIR/test_constant_folding.c"
run_test "$TEST_DIR/test_multiplas_constantes.c"
run_test "$TEST_DIR/test_invalidacao.c"
run_test "$TEST_DIR/test_float.c"
run_test "$TEST_DIR/test_unario.c"
run_test "$TEST_DIR/test_condicionais.c"
run_test "$TEST_DIR/test_cadeia.c"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   TESTES CONCLUÍDOS${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Verifique as otimizações marcadas com [OPT] acima."
echo "Número de otimizações deve corresponder às expectativas de cada teste."
