// Teste léxico: identificadores com underscores e combinações

int _x;
int x1;
int x_long_nome__com__underscore;

int main(void) {
    _x = 1;
    x1 = _x + 2;
    x_long_nome__com__underscore = x1;
    return 0;
}
