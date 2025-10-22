#!/usr/bin/env bash
set -euo pipefail

cat <<'TXT'
Exemplos de uso (C):

1) Compilar e rodar um teste específico:
   gcc -Wall -Wextra -std=c11 tests_c/test_if.c -o test_if.out
   ./test_if.out

2) Rodar a suíte completa:
   ./run_c_tests.sh

3) Validar erros de compilação:
   ./test_c_errors.sh

4) Criar e executar um teste rápido:
   cat > /tmp/quick.c <<'EOF'
   #include <stdio.h>
   int main(void){ printf("quick\n"); return 0; }
   EOF
   gcc -Wall -Wextra -std=c11 /tmp/quick.c -o /tmp/quick.out && /tmp/quick.out

TXT
