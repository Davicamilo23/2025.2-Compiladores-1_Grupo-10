#include <stdio.h>
int main(void) {
    int x = 5 + "3"; // invalid operands
    printf("%d\n", x);
    return 0;
}
