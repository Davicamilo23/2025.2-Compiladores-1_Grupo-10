#!/usr/bin/env bash
set -euo pipefail

PS3="Selecione uma opção (0 para sair): "
options=(
  "Compilar+rodar test_simple.c"
  "Compilar+rodar test_if.c"
  "Compilar+rodar test_while.c"
  "Compilar+rodar test_ptr_decl_assign.c"
  "Compilar+rodar test_ptr_chain.c"
  "Executar suíte completa (run_c_tests.sh)"
  "Validar casos de erro (test_c_errors.sh)"
  "Criar e rodar teste rápido (quick.c)"
)

select opt in "${options[@]}" "Sair"; do
  case $REPLY in
    1) gcc -Wall -Wextra -std=c11 tests_c/test_simple.c -o tests_c/test_simple.out && tests_c/test_simple.out ;;
    2) gcc -Wall -Wextra -std=c11 tests_c/test_if.c -o tests_c/test_if.out && tests_c/test_if.out ;;
    3) gcc -Wall -Wextra -std=c11 tests_c/test_while.c -o tests_c/test_while.out && tests_c/test_while.out ;;
    4) gcc -Wall -Wextra -std=c11 tests_c/test_ptr_decl_assign.c -o tests_c/test_ptr_decl_assign.out && tests_c/test_ptr_decl_assign.out ;;
    5) gcc -Wall -Wextra -std=c11 tests_c/test_ptr_chain.c -o tests_c/test_ptr_chain.out && tests_c/test_ptr_chain.out ;;
    6) ./run_c_tests.sh ;;
    7) ./test_c_errors.sh ;;
    8) cat > /tmp/quick.c <<'EOF'
#include <stdio.h>
int main(void){ printf("quick\n"); return 0; }
EOF
       gcc -Wall -Wextra -std=c11 /tmp/quick.c -o /tmp/quick.out && /tmp/quick.out ;;
    9) echo "Saindo..."; break ;;
    *) echo "Opção inválida!";;
  esac
done
