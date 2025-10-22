#include <stdio.h>

static void foo(void) {
    int x = 2;
    printf("inner_x=%d\n", x);
}

int main(void) {
    int x = 1;
    foo();
    printf("outer_x=%d\n", x);
    return 0;
}
