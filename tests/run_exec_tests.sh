#!/usr/bin/env bash
set -euo pipefail

COMPILER=./c2python
PYTHON=python3

echo "======================================"
echo "  ▶️  Testes de Execução (C → Python)"
echo "======================================"
echo ""

if [ ! -x "$COMPILER" ]; then
  echo "❌ Compilador '$COMPILER' não encontrado ou não executável."
  echo "   Rode 'make' antes de executar os testes."
  exit 1
fi

ok=0
fail=0

run_exec_test() {
  local src="$1"
  local expected="$2"

  echo ">> EXEC: $src"
  echo "----------------------------------"

  # Gera Python
  if ! "$COMPILER" "$src" > /tmp/exec_compile.log 2>&1; then
    echo "❌ FAIL - compilação falhou"
    cat /tmp/exec_compile.log
    fail=$((fail+1))
    echo
    return
  fi

  # Executa Python gerado
  if ! out=$($PYTHON saida.py); then
    echo "❌ FAIL - erro ao executar saida.py"
    echo "$out"
    fail=$((fail+1))
    echo
    return
  fi

  if [ "$out" != "$expected" ]; then
    echo "❌ FAIL - saída inesperada"
    echo "Esperado:"
    printf '%s
' "$expected"
    echo "Obtido:"
    printf '%s
' "$out"
    fail=$((fail+1))
  else
    echo "✅ OK   - saída bate com o esperado"
    ok=$((ok+1))
  fi
  echo
}

# 1) Testa apenas impressão simples
run_exec_test tests/test_print.c "hello"

# 2) Testa chamada de função e retorno de inteiro
run_exec_test tests/test_function.c "8"

# 3) Testa laço while simples
# Saída esperada: 0\n1\n2
run_exec_test tests/test_while.c $'0\n1\n2'

echo "--------------------------------------"
echo "RESUMO EXEC: OK=$ok | FAIL=$fail"
echo "--------------------------------------"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
