#ifndef OTIMIZADOR_H
#define OTIMIZADOR_H

#include "../tabela_simbolos/ast.h"

// MÓDULO DE OTIMIZAÇÃO - PROPAGAÇÃO DE CONSTANTES

//Estrutura que rmazenar valores constantes conhecidos
typedef struct InfoConstante {
    char nome[32];
    int eh_constante;     
    Tipo tipo;
    union {
        int valor_int;
        float valor_float;
        char valor_char;
    } valor;
    struct InfoConstante *proximo; 
} InfoConstante;

//Tabela de constantes
#define TAM_CONST 211

// Inicializa a tabela de constantes (limpa todos os buckets)

void inicializarTabelaConstantes(void);

void limparTabelaConstantes(void);

//Registra uma variável como constante com seu valor

void registrarConstante(const char *nome, Tipo tipo, int valor_int, float valor_float);


InfoConstante* buscarConstante(const char *nome);

void invalidarConstante(const char *nome);

/**
 * Passo de propagação de constantes
 * - Identifica variáveis inicializadas com literais
 * - Substitui usos de variáveis constantes por seus valores
 * - Invalida constantes quando reatribuídas com valores não-literais
 * 
 * @param ast Nó da AST a otimizar
 * @return AST otimizada (pode ser o mesmo nó ou novo nó)
 */
Ast* passePropagacaoConstantes(Ast *ast);

/**
 * Passo de constant folding (dobramento de constantes)
 * - Avalia expressões com literais em tempo de compilação
 * - Exemplo: 2 + 3 → 5, 10 * 0 → 0
 * 
 * @param ast Nó da AST a otimizar
 * @return AST otimizada (pode ser o mesmo nó ou novo nó)
 */
Ast* passeConstantFolding(Ast *ast);

void imprimirEstatisticasOtimizacao(void);

#endif 
