// Teste 4: Invalidação de constantes
// Variáveis reatribuídas com valores não-literais não devem ser propagadas

int x = 5;
int y = x + 3;    
x = y * 2;         
int z = x + 1;     