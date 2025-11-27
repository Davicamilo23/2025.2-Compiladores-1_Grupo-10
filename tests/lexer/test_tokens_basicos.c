// Teste léxico: tokens básicos, operadores e literais simples

int main(void) {
    int x = 10;
    float y = 3.14;
    char c = 'a';
    const char *str = "hello\nworld";

    x = x + 1 - 2 * 3 / 4 % 5;

    if (x > 0 && y < 10.0 || c == 'a') {
        x++;
    }

    return 0;
}
