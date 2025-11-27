#!/usr/bin/env bash
set -euo pipefail

COMPILER=./c2python

echo "======================================"
echo "  🌳 Testes de AST (estrutura da árvore)"
echo "======================================"
echo ""

if [ ! -x "$COMPILER" ]; then
  echo "❌ Compilador '$COMPILER' não encontrado ou não executável."
  echo "   Rode 'make' antes de executar os testes."
  exit 1
fi

ok=0
fail=0

run_ast_test() {
  local src="$1"
  shift
  local patterns=("$@")

  echo ">> AST: $src"
  echo "----------------------------------"

  if ! "$COMPILER" "$src" > /tmp/ast_out.log 2>&1; then
    echo "❌ FAIL - compilação falhou para $src"
    cat /tmp/ast_out.log
    fail=$((fail+1))
    echo
    return
  fi

  local missing=0
  for p in "${patterns[@]}"; do
    if ! grep -q "$p" /tmp/ast_out.log; then
      echo "❌ FAIL - nó AST esperado não encontrado: '$p'"
      missing=1
    fi
  done

  if [ "$missing" -eq 0 ]; then
    echo "✅ OK   - todos os nós esperados encontrados"
    ok=$((ok+1))
  else
    fail=$((fail+1))
  fi
  echo
}

# Casos básicos usando arquivos já existentes
run_ast_test tests/test_if.c           "PROGRAMA" "DECL_FUNCAO" "IF" "OP_BINARIO"
run_ast_test tests/test_if_else.c      "IF_ELSE"
run_ast_test tests/test_while.c        "WHILE"
run_ast_test tests/test_nested_blocks.c "BLOCO"
run_ast_test tests/test_ptr_decl_assign.c "DECL_VAR" "OP_BINARIO"

echo "--------------------------------------"
echo "RESUMO AST: OK=$ok | FAIL=$fail"
echo "--------------------------------------"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
