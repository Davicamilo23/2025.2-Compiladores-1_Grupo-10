// Teste: Atribuição de int para ponteiro (inválido)
// Espera-se: Erro semântico - tipos incompatíveis em atribuição

int main(void) {
    int x = 10;
    int *p;
    p = x;  // ERRO: atribuição int -> int*
    return 0;
}
