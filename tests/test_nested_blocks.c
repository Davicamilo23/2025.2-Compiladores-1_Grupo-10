#include <stdio.h>

int main(void) {
    int x = 10;
    if (x > 0) {
        printf("A\n");
        if (x > 5) {
            printf("A1\n");
        }
    }
    printf("B\n");
    return 0;
}
