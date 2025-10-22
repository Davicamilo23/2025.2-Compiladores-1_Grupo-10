#include <stdio.h>

int main(void) {
    int x = 0;
    int *p = &x;
    while (*p < 5) {
        *p = *p + 1;
        if (*p > 2) {
            x = 100;
            break;
        }
    }
    printf("x=%d\n", x);
    return 0;
}
