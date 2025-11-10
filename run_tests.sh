#!/usr/bin/env bash
set -euo pipefail

COMPILER="./c2python"
ROOT="tests"
ok=0; fail=0

# --- Detecta pasta conforme parâmetro ---
if [ $# -eq 0 ]; then
  TARGET="$ROOT"                  # padrão: apenas raiz
  MODE="normal"
elif [ "$1" == "tipos" ]; then
  TARGET="$ROOT/tipos"
  MODE="normal"
elif [ "$1" == "errors" ]; then
  TARGET="$ROOT/errors"
  MODE="errors"
else
  echo "Uso: $0 [tipos|errors]"
  echo "Sem parâmetros: roda apenas os testes na raiz de '$ROOT'"
  exit 1
fi

echo "== Rodando testes em $TARGET (modo $MODE) =="

# Define profundidade de busca
if [ "$TARGET" == "$ROOT" ]; then
  FIND_OPTS=(-maxdepth 1)
else
  FIND_OPTS=()
fi

# Loop principal
for f in $(find "$TARGET" "${FIND_OPTS[@]}" -type f -name "*.c" | sort); do
  echo
  echo ">> TESTE: $f"
  echo "----------------------------------"

  if [ "$MODE" == "errors" ]; then
    # Espera falhar
    if cat "$f" | $COMPILER > /tmp/out.log 2>&1; then
      echo "❌ ERRO: compilou mas deveria falhar -> $f"
      fail=$((fail+1))
    else
      echo "✅ OK: falhou como esperado -> $f"
      ok=$((ok+1))
    fi
  else
    # Espera funcionar
    if cat "$f" | $COMPILER > /tmp/out.log 2>&1; then
      echo "✅ OK   - $f"
      ok=$((ok+1))
    else
      echo "❌ FAIL - $f"
      cat /tmp/out.log
      fail=$((fail+1))
    fi
  fi
done

echo
echo "----------------------------------"
echo "RESUMO FINAL: OK=$ok | FAIL=$fail"
echo "----------------------------------"
