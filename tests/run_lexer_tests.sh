#!/usr/bin/env bash
set -euo pipefail

COMPILER=./c2python

echo "======================================"
echo "  🧪 Testes de Léxico (Flex)"
echo "======================================"
echo ""

if [ ! -x "$COMPILER" ]; then
  echo "❌ Compilador '$COMPILER' não encontrado ou não executável."
  echo "   Rode 'make' antes de executar os testes."
  exit 1
fi

TARGET_DIR="tests/lexer"

ok=0
fail=0

for f in "$TARGET_DIR"/*.c; do
  echo ">> LÉXICO: $f"
  echo "----------------------------------"
  if "$COMPILER" "$f" > /tmp/lexer_out.log 2>&1; then
    echo "✅ OK   - $f"
    ok=$((ok+1))
  else
    echo "❌ FAIL - $f"
    cat /tmp/lexer_out.log
    fail=$((fail+1))
  fi
  echo
done

echo "----------------------------------"
echo "RESUMO LÉXICO: OK=$ok | FAIL=$fail"
echo "----------------------------------"

if [ "$fail" -ne 0 ]; then
  exit 1
fi
