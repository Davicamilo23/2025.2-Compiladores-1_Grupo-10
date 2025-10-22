#include <stdio.h>

int main(void) {
    int x = 1;
    int *p = &x;
    int **pp = &p;
    **pp = 42;
    printf("x=%d\n", x);
    return 0;
}
