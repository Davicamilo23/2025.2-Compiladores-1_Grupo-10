#include <stdio.h>

int main(void) {
    int n = 3;
    if (n < 0) {
        printf("negative\n");
    } else if (n < 5) {
        printf("small\n");
    } else {
        printf("large\n");
    }
    return 0;
}
