#include <stdio.h>

int main(void) {
    int a = 5;
    int b = 3;
    int soma = a + b;

    if (soma > 5) {
        printf("A soma é maior que 5\n");
    } else {
        printf("A soma é menor ou igual a 5\n");
    }

    return 0;
}