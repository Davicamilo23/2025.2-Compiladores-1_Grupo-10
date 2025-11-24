#ifndef OTIMIZADOR_H
#define OTIMIZADOR_H

#include "../tabela_simbolos/ast.h"

// MÓDULO DE OTIMIZAÇÃO - PROPAGAÇÃO DE CONSTANTES

// Estrutura que armazena valores constantes conhecidos
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

// Tabela de constantes
#define TAM_CONST 211

// Inicializa a tabela de constantes (limpa todos os buckets)
void inicializarTabelaConstantes(void);

// Libera memória e limpa a tabela de constantes
void limparTabelaConstantes(void);

// Registra uma variável como constante com seu valor
void registrarConstante(const char *nome, Tipo tipo, int valor_int, float valor_float);

// Busca informação de constante pelo nome (ou NULL se não encontrada)
InfoConstante* buscarConstante(const char *nome);

// Invalida uma constante (deixa de ser considerada constante)
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

/**
 * Passo de simplificação de expressões
 * - Simplifica expressões algébricas e lógicas básicas
 *   Ex.: x + 0 → x, x * 1 → x, x - x → 0, x / 1 → x,
 *        x == x → 1, x != x → 0, x && 0 → 0, x || 1 → 1,
 *        !(!x) → x, -(-x) → x, etc.
 * 
 * @param ast Nó da AST a otimizar
 * @return AST otimizada (pode ser o mesmo nó ou novo nó)
 */
Ast* passeSimplificacaoExpressoes(Ast *ast);

/**
 * Passo de remoção de código morto na AST
 * - Remove:
 *    * if (0) { ... }           → nada (ou else, se existir)
 *    * if (1) { then } else { } → apenas then
 *    * while (0) { ... }        → nada
 *    * expressão solta sem efeito colateral (ex.: 1 + 2;)
 * - Propaga remoção em listas de statements, blocos e funções.
 * 
 * @param ast Nó da AST a otimizar (programa, função, bloco, etc.)
 * @return AST otimizada (pode ser o mesmo nó ou NULL, se eliminado)
 */
Ast* passeRemocaoCodigoMorto(Ast *ast);

// Imprime estatísticas das otimizações realizadas
void imprimirEstatisticasOtimizacao(void);

#endif
