#include <stdio.h>

static int somar(int a, int b) { return a + b; }

int main(void) {
    int resultado = somar(5, 3);
    printf("%d\n", resultado);
    return 0;
}
