#include <stdio.h>

static void teste(void) {
    int x = 5;
    (void)x;
}

int main(void) {
    teste();
    return 0;
}
