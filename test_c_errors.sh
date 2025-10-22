#!/usr/bin/env bash
set -euo pipefail

CC=${CC:-gcc}
CFLAGS=${CFLAGS:-"-Wall -Wextra -std=c11"}
DIR="tests_c/errors"

echo "== Compilando casos de ERRO (espera-se falha) =="
rc_ok=0; rc_bad=0

for f in $(find "$DIR" -name "*.c" | sort); do
  echo ">> CHECK $(basename "$f")"
  if $CC $CFLAGS "$f" -o "${f%.c}.out" 2>/dev/null; then
    echo "!! ERRO: compilou mas deveria falhar -> $(basename "$f")"
    rc_bad=$((rc_bad+1))
  else
    echo "OK: falhou como esperado -> $(basename "$f")"
    rc_ok=$((rc_ok+1))
  fi
done

echo "-- RESUMO: OK=$rc_ok, INDEVIDOS=$rc_bad --"
test $rc_bad -eq 0
