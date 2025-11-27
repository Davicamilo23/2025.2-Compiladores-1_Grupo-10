// Teste: Operação aritmética entre dois ponteiros (inválida)
// Espera-se: Erro semântico - soma entre ponteiros não suportada

int main(void) {
    int *p;
    int *q;
    int *r = p + q;  // ERRO: soma entre dois ponteiros
    return 0;
}
