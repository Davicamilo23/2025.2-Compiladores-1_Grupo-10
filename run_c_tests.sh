#!/usr/bin/env bash
set -euo pipefail

CC=${CC:-gcc}
CFLAGS=${CFLAGS:-"-Wall -Wextra -Werror -std=c11"}
ROOT="tests_c"

echo "== Compilando e executando testes C =="
ok=0; fail=0

# compila e executa os testes válidos do diretório raiz (exclui subdir errors/)
for f in $(find "$ROOT" -maxdepth 1 -name "*.c" | sort); do
  exe="${f%.c}.out"
  echo ">> COMP $(basename "$f")"
  if $CC $CFLAGS "$f" -o "$exe"; then
    echo ">> RUN  $(basename "$exe")"
    "$exe" || true
    ok=$((ok+1))
  else
    echo "!! FAIL COMPILE $(basename "$f")"
    fail=$((fail+1))
  fi
  echo
done

echo "-- RESUMO: OK=$ok, FAIL=$fail --"
