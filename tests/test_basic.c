#include <stdio.h>

int main(void) {
    int x = 10;
    int y = 20;
    int z = x + y;
    (void)z; /* unused in this test */
    printf("Hello World\n");
    return 0;
}
