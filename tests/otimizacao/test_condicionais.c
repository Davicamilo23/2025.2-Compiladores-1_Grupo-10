// Teste 7: Expressões condicionais
// Propagação dentro de if/while

int flag = 1;
int contador = 0;

if (flag) {
    contador = contador + 5;  // flag = 1 (constante)
}

int limite = 10;
while (contador < limite) {  // limite = 10 (constante)
    contador = contador + 1;
}
