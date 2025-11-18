#include "otimizador.h"
#include "../tabela_simbolos/tabela.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* ============================================
 * TABELA DE CONSTANTES (HASH TABLE)
 * ============================================ */

static InfoConstante *tabela_constantes[TAM_CONST] = {NULL};

// Contadores de estatísticas
static int stats_folding = 0;
static int stats_propagacao = 0;

// Hash simples (reutiliza lógica de tabela.c)
static unsigned hash_const(const char *s) {
    unsigned h = 0;
    while (*s) {
        h = (h << 4) + *s++;
    }
    return h % TAM_CONST;
}

void inicializarTabelaConstantes(void) {
    for (int i = 0; i < TAM_CONST; i++) {
        tabela_constantes[i] = NULL;
    }
    stats_folding = 0;
    stats_propagacao = 0;
}

void limparTabelaConstantes(void) {
    for (int i = 0; i < TAM_CONST; i++) {
        InfoConstante *atual = tabela_constantes[i];
        while (atual) {
            InfoConstante *prox = atual->proximo;
            free(atual);
            atual = prox;
        }
        tabela_constantes[i] = NULL;
    }
}

void registrarConstante(const char *nome, Tipo tipo, int valor_int, float valor_float) {
    unsigned idx = hash_const(nome);
    
    // Verificar se já existe
    InfoConstante *c = buscarConstante(nome);
    if (c) {
        // Atualizar valores
        c->eh_constante = 1;
        c->tipo = tipo;
        if (tipo == TIPO_INT) c->valor.valor_int = valor_int;
        else if (tipo == TIPO_FLOAT) c->valor.valor_float = valor_float;
        else if (tipo == TIPO_CHAR) c->valor.valor_char = (char)valor_int;
        return;
    }
    
    // Criar nova entrada
    InfoConstante *nova = malloc(sizeof(InfoConstante));
    if (!nova) {
        fprintf(stderr, "Erro: falha ao alocar memória para constante\n");
        return;
    }
    
    strcpy(nova->nome, nome);
    nova->eh_constante = 1;
    nova->tipo = tipo;
    if (tipo == TIPO_INT) nova->valor.valor_int = valor_int;
    else if (tipo == TIPO_FLOAT) nova->valor.valor_float = valor_float;
    else if (tipo == TIPO_CHAR) nova->valor.valor_char = (char)valor_int;
    
    // Inserir no início da lista encadeada
    nova->proximo = tabela_constantes[idx];
    tabela_constantes[idx] = nova;
}

InfoConstante* buscarConstante(const char *nome) {
    unsigned idx = hash_const(nome);
    InfoConstante *c = tabela_constantes[idx];
    
    while (c) {
        if (strcmp(c->nome, nome) == 0) {
            return c;
        }
        c = c->proximo;
    }
    
    return NULL;
}

void invalidarConstante(const char *nome) {
    InfoConstante *c = buscarConstante(nome);
    if (c) {
        c->eh_constante = 0;
    }
}

/* ============================================
 * HELPERS PARA CRIAR LITERAIS
 * ============================================ */

static Ast* criarLitInt(int val) {
    return criarLiteralInt(val, 0);
}

static Ast* criarLitFloat(float val) {
    return criarLiteralFloat(val, 0);
}

static Ast* criarLitChar(char val) {
    return criarLiteralChar(val, 0);
}

/* ============================================
 * PASSO 1: CONSTANT FOLDING
 * Avalia expressões com literais em tempo de compilação
 * ============================================ */

Ast* passeConstantFolding(Ast *ast) {
    if (!ast) return NULL;
    
    switch (ast->tipo) {
        case AST_OP_BINARIO: {
            // Recursivamente otimizar operandos primeiro
            ast->dados.op_binario.esquerda = passeConstantFolding(ast->dados.op_binario.esquerda);
            ast->dados.op_binario.direita = passeConstantFolding(ast->dados.op_binario.direita);
            
            Ast *esq = ast->dados.op_binario.esquerda;
            Ast *dir = ast->dados.op_binario.direita;
            
            // Folding para INT op INT
            if (esq->tipo == AST_LITERAL_INT && dir->tipo == AST_LITERAL_INT) {
                int a = esq->dados.literal.valor_int;
                int b = dir->dados.literal.valor_int;
                int resultado = 0;
                int pode_fold = 1;
                
                switch (ast->dados.op_binario.op) {
                    case OP_MAIS:  resultado = a + b; break;
                    case OP_MENOS: resultado = a - b; break;
                    case OP_MULT:  resultado = a * b; break;
                    case OP_DIV:   
                        if (b != 0) resultado = a / b; 
                        else { pode_fold = 0; fprintf(stderr, "[OPT] Aviso: divisão por zero evitada\n"); }
                        break;
                    case OP_MOD:   
                        if (b != 0) resultado = a % b; 
                        else { pode_fold = 0; fprintf(stderr, "[OPT] Aviso: módulo por zero evitado\n"); }
                        break;
                    case OP_EQ: resultado = (a == b); break;
                    case OP_NE: resultado = (a != b); break;
                    case OP_LT: resultado = (a < b); break;
                    case OP_LE: resultado = (a <= b); break;
                    case OP_GT: resultado = (a > b); break;
                    case OP_GE: resultado = (a >= b); break;
                    case OP_AND: resultado = (a && b); break;
                    case OP_OR: resultado = (a || b); break;
                    default: pode_fold = 0;
                }
                
                if (pode_fold) {
                    printf("[OPT] Constant folding: %d op %d = %d\n", a, b, resultado);
                    stats_folding++;
                    // Liberar AST antiga (não liberar operandos pois foram criados pelo parser)
                    Ast *novo = criarLitInt(resultado);
                    novo->tipo_dado = ast->tipo_dado;
                    novo->linha = ast->linha;
                    return novo;
                }
            }
            
            // Folding para FLOAT op FLOAT
            if (esq->tipo == AST_LITERAL_FLOAT && dir->tipo == AST_LITERAL_FLOAT) {
                float a = esq->dados.literal.valor_float;
                float b = dir->dados.literal.valor_float;
                float resultado = 0.0f;
                int pode_fold = 1;
                
                switch (ast->dados.op_binario.op) {
                    case OP_MAIS:  resultado = a + b; break;
                    case OP_MENOS: resultado = a - b; break;
                    case OP_MULT:  resultado = a * b; break;
                    case OP_DIV:   
                        if (b != 0.0f) resultado = a / b; 
                        else { pode_fold = 0; fprintf(stderr, "[OPT] Aviso: divisão por zero evitada\n"); }
                        break;
                    default: pode_fold = 0;
                }
                
                if (pode_fold) {
                    printf("[OPT] Constant folding (float): %.2f op %.2f = %.2f\n", a, b, resultado);
                    stats_folding++;
                    Ast *novo = criarLitFloat(resultado);
                    novo->tipo_dado = ast->tipo_dado;
                    novo->linha = ast->linha;
                    return novo;
                }
            }
            
            // Folding misto INT op FLOAT
            if ((esq->tipo == AST_LITERAL_INT && dir->tipo == AST_LITERAL_FLOAT) ||
                (esq->tipo == AST_LITERAL_FLOAT && dir->tipo == AST_LITERAL_INT)) {
                
                float a = (esq->tipo == AST_LITERAL_INT) ? (float)esq->dados.literal.valor_int : esq->dados.literal.valor_float;
                float b = (dir->tipo == AST_LITERAL_INT) ? (float)dir->dados.literal.valor_int : dir->dados.literal.valor_float;
                float resultado = 0.0f;
                int pode_fold = 1;
                
                switch (ast->dados.op_binario.op) {
                    case OP_MAIS:  resultado = a + b; break;
                    case OP_MENOS: resultado = a - b; break;
                    case OP_MULT:  resultado = a * b; break;
                    case OP_DIV:   
                        if (b != 0.0f) resultado = a / b; 
                        else pode_fold = 0;
                        break;
                    default: pode_fold = 0;
                }
                
                if (pode_fold) {
                    printf("[OPT] Constant folding (mixed): %.2f op %.2f = %.2f\n", a, b, resultado);
                    stats_folding++;
                    Ast *novo = criarLitFloat(resultado);
                    novo->tipo_dado = TIPO_FLOAT;
                    novo->linha = ast->linha;
                    return novo;
                }
            }
            
            return ast;
        }
        
        case AST_OP_UNARIO: {
            ast->dados.op_unario.operando = passeConstantFolding(ast->dados.op_unario.operando);
            Ast *op = ast->dados.op_unario.operando;
            
            // -INT
            if (op->tipo == AST_LITERAL_INT && ast->dados.op_unario.op == OP_UN_MENOS) {
                int val = -op->dados.literal.valor_int;
                printf("[OPT] Constant folding: -(%d) = %d\n", op->dados.literal.valor_int, val);
                stats_folding++;
                Ast *novo = criarLitInt(val);
                novo->tipo_dado = TIPO_INT;
                novo->linha = ast->linha;
                return novo;
            }
            
            // -FLOAT
            if (op->tipo == AST_LITERAL_FLOAT && ast->dados.op_unario.op == OP_UN_MENOS) {
                float val = -op->dados.literal.valor_float;
                printf("[OPT] Constant folding: -(%.2f) = %.2f\n", op->dados.literal.valor_float, val);
                stats_folding++;
                Ast *novo = criarLitFloat(val);
                novo->tipo_dado = TIPO_FLOAT;
                novo->linha = ast->linha;
                return novo;
            }
            
            // !INT (negação lógica)
            if (op->tipo == AST_LITERAL_INT && ast->dados.op_unario.op == OP_UN_NOT) {
                int val = !op->dados.literal.valor_int;
                printf("[OPT] Constant folding: !(%d) = %d\n", op->dados.literal.valor_int, val);
                stats_folding++;
                Ast *novo = criarLitInt(val);
                novo->tipo_dado = TIPO_INT;
                novo->linha = ast->linha;
                return novo;
            }
            
            return ast;
        }
        
        case AST_LISTA:
            if (ast->dados.lista.item)
                ast->dados.lista.item = passeConstantFolding(ast->dados.lista.item);
            if (ast->dados.lista.proximo)
                ast->dados.lista.proximo = passeConstantFolding(ast->dados.lista.proximo);
            return ast;
            
        case AST_DECL_VAR:
            if (ast->dados.declaracao.inicializador)
                ast->dados.declaracao.inicializador = passeConstantFolding(ast->dados.declaracao.inicializador);
            return ast;
            
        case AST_ATRIBUICAO:
            if (ast->dados.atribuicao.valor)
                ast->dados.atribuicao.valor = passeConstantFolding(ast->dados.atribuicao.valor);
            return ast;
            
        case AST_IF:
        case AST_IF_ELSE:
            if (ast->dados.if_stmt.condicao)
                ast->dados.if_stmt.condicao = passeConstantFolding(ast->dados.if_stmt.condicao);
            if (ast->dados.if_stmt.bloco_then)
                ast->dados.if_stmt.bloco_then = passeConstantFolding(ast->dados.if_stmt.bloco_then);
            if (ast->dados.if_stmt.bloco_else)
                ast->dados.if_stmt.bloco_else = passeConstantFolding(ast->dados.if_stmt.bloco_else);
            return ast;
            
        case AST_WHILE:
            if (ast->dados.while_stmt.condicao)
                ast->dados.while_stmt.condicao = passeConstantFolding(ast->dados.while_stmt.condicao);
            if (ast->dados.while_stmt.corpo)
                ast->dados.while_stmt.corpo = passeConstantFolding(ast->dados.while_stmt.corpo);
            return ast;
            
        case AST_FOR:
            if (ast->dados.for_stmt.inicializacao)
                ast->dados.for_stmt.inicializacao = passeConstantFolding(ast->dados.for_stmt.inicializacao);
            if (ast->dados.for_stmt.condicao)
                ast->dados.for_stmt.condicao = passeConstantFolding(ast->dados.for_stmt.condicao);
            if (ast->dados.for_stmt.incremento)
                ast->dados.for_stmt.incremento = passeConstantFolding(ast->dados.for_stmt.incremento);
            if (ast->dados.for_stmt.corpo)
                ast->dados.for_stmt.corpo = passeConstantFolding(ast->dados.for_stmt.corpo);
            return ast;
            
        case AST_RETURN:
            if (ast->dados.return_stmt.expressao)
                ast->dados.return_stmt.expressao = passeConstantFolding(ast->dados.return_stmt.expressao);
            return ast;
            
        case AST_BLOCO:
        case AST_PROGRAMA:
        case AST_EXPR_STMT:
            if (ast->dados.bloco.statements)
                ast->dados.bloco.statements = passeConstantFolding(ast->dados.bloco.statements);
            return ast;
            
        case AST_CHAMADA_FUNCAO:
            if (ast->dados.chamada.argumentos)
                ast->dados.chamada.argumentos = passeConstantFolding(ast->dados.chamada.argumentos);
            return ast;
            
        case AST_INDEXACAO:
            if (ast->dados.indexacao.array)
                ast->dados.indexacao.array = passeConstantFolding(ast->dados.indexacao.array);
            if (ast->dados.indexacao.indice)
                ast->dados.indexacao.indice = passeConstantFolding(ast->dados.indexacao.indice);
            return ast;
            
        default:
            return ast;
    }
}


//Substitui variáveis por valores literais quando possível
Ast* passePropagacaoConstantes(Ast *ast) {
    if (!ast) return NULL;
    
    switch (ast->tipo) {
        case AST_DECL_VAR: {
            // Se inicializada com literal, registrar como constante
            if (ast->dados.declaracao.inicializador) {
                Ast *init = ast->dados.declaracao.inicializador;
                
                if (init->tipo == AST_LITERAL_INT) {
                    int val = init->dados.literal.valor_int;
                    registrarConstante(ast->dados.declaracao.nome, TIPO_INT, val, 0.0f);
                    printf("[OPT] Registrada constante: %s = %d\n", ast->dados.declaracao.nome, val);
                }
                else if (init->tipo == AST_LITERAL_FLOAT) {
                    float val = init->dados.literal.valor_float;
                    registrarConstante(ast->dados.declaracao.nome, TIPO_FLOAT, 0, val);
                    printf("[OPT] Registrada constante: %s = %.2f\n", ast->dados.declaracao.nome, val);
                }
                else if (init->tipo == AST_LITERAL_CHAR) {
                    char val = init->dados.literal.valor_char;
                    registrarConstante(ast->dados.declaracao.nome, TIPO_CHAR, val, 0.0f);
                    printf("[OPT] Registrada constante: %s = '%c'\n", ast->dados.declaracao.nome, val);
                }
                
                ast->dados.declaracao.inicializador = passePropagacaoConstantes(ast->dados.declaracao.inicializador);
            }
            return ast;
        }
        
        case AST_ATRIBUICAO: {
            // Processar valor primeiro
            ast->dados.atribuicao.valor = passePropagacaoConstantes(ast->dados.atribuicao.valor);
            
            // Reatribuição: verificar se mantém constante ou invalida
            if (ast->dados.atribuicao.variavel && ast->dados.atribuicao.variavel->tipo == AST_IDENTIFICADOR) {
                const char *nome = ast->dados.atribuicao.variavel->dados.identificador.nome;
                Ast *val = ast->dados.atribuicao.valor;
                
                // Se atribui literal, pode ser (nova) constante
                if (val->tipo == AST_LITERAL_INT) {
                    int v = val->dados.literal.valor_int;
                    registrarConstante(nome, TIPO_INT, v, 0.0f);
                    printf("[OPT] Atualizada constante: %s = %d\n", nome, v);
                }
                else if (val->tipo == AST_LITERAL_FLOAT) {
                    float v = val->dados.literal.valor_float;
                    registrarConstante(nome, TIPO_FLOAT, 0, v);
                    printf("[OPT] Atualizada constante: %s = %.2f\n", nome, v);
                }
                else {
                    // Não é literal → invalidar
                    invalidarConstante(nome);
                    printf("[OPT] Invalidada constante: %s (atribuição não literal)\n", nome);
                }
            }
            
            return ast;
        }
        
        case AST_IDENTIFICADOR: {
            // Substituir por literal se constante
            InfoConstante *c = buscarConstante(ast->dados.identificador.nome);
            if (c && c->eh_constante) {
                Ast *novo = NULL;
                
                if (c->tipo == TIPO_INT) {
                    printf("[OPT] Propagada constante: %s → %d\n", ast->dados.identificador.nome, c->valor.valor_int);
                    novo = criarLitInt(c->valor.valor_int);
                    stats_propagacao++;
                }
                else if (c->tipo == TIPO_FLOAT) {
                    printf("[OPT] Propagada constante: %s → %.2f\n", ast->dados.identificador.nome, c->valor.valor_float);
                    novo = criarLitFloat(c->valor.valor_float);
                    stats_propagacao++;
                }
                else if (c->tipo == TIPO_CHAR) {
                    printf("[OPT] Propagada constante: %s → '%c'\n", ast->dados.identificador.nome, c->valor.valor_char);
                    novo = criarLitChar(c->valor.valor_char);
                    stats_propagacao++;
                }
                
                if (novo) {
                    novo->tipo_dado = c->tipo;
                    novo->linha = ast->linha;
                    return novo;
                }
            }
            return ast;
        }
        
        case AST_OP_BINARIO:
            ast->dados.op_binario.esquerda = passePropagacaoConstantes(ast->dados.op_binario.esquerda);
            ast->dados.op_binario.direita = passePropagacaoConstantes(ast->dados.op_binario.direita);
            return ast;
            
        case AST_OP_UNARIO:
            ast->dados.op_unario.operando = passePropagacaoConstantes(ast->dados.op_unario.operando);
            return ast;
            
        case AST_LISTA:
            if (ast->dados.lista.item)
                ast->dados.lista.item = passePropagacaoConstantes(ast->dados.lista.item);
            if (ast->dados.lista.proximo)
                ast->dados.lista.proximo = passePropagacaoConstantes(ast->dados.lista.proximo);
            return ast;
            
        case AST_IF:
        case AST_IF_ELSE:
            if (ast->dados.if_stmt.condicao)
                ast->dados.if_stmt.condicao = passePropagacaoConstantes(ast->dados.if_stmt.condicao);
            if (ast->dados.if_stmt.bloco_then)
                ast->dados.if_stmt.bloco_then = passePropagacaoConstantes(ast->dados.if_stmt.bloco_then);
            if (ast->dados.if_stmt.bloco_else)
                ast->dados.if_stmt.bloco_else = passePropagacaoConstantes(ast->dados.if_stmt.bloco_else);
            return ast;
            
        case AST_WHILE:
            if (ast->dados.while_stmt.condicao)
                ast->dados.while_stmt.condicao = passePropagacaoConstantes(ast->dados.while_stmt.condicao);
            if (ast->dados.while_stmt.corpo)
                ast->dados.while_stmt.corpo = passePropagacaoConstantes(ast->dados.while_stmt.corpo);
            return ast;
            
        case AST_FOR:
            if (ast->dados.for_stmt.inicializacao)
                ast->dados.for_stmt.inicializacao = passePropagacaoConstantes(ast->dados.for_stmt.inicializacao);
            if (ast->dados.for_stmt.condicao)
                ast->dados.for_stmt.condicao = passePropagacaoConstantes(ast->dados.for_stmt.condicao);
            if (ast->dados.for_stmt.incremento)
                ast->dados.for_stmt.incremento = passePropagacaoConstantes(ast->dados.for_stmt.incremento);
            if (ast->dados.for_stmt.corpo)
                ast->dados.for_stmt.corpo = passePropagacaoConstantes(ast->dados.for_stmt.corpo);
            return ast;
            
        case AST_RETURN:
            if (ast->dados.return_stmt.expressao)
                ast->dados.return_stmt.expressao = passePropagacaoConstantes(ast->dados.return_stmt.expressao);
            return ast;
            
        case AST_BLOCO:
        case AST_PROGRAMA:
        case AST_EXPR_STMT:
            if (ast->dados.bloco.statements)
                ast->dados.bloco.statements = passePropagacaoConstantes(ast->dados.bloco.statements);
            return ast;
            
        case AST_CHAMADA_FUNCAO:
            if (ast->dados.chamada.argumentos)
                ast->dados.chamada.argumentos = passePropagacaoConstantes(ast->dados.chamada.argumentos);
            return ast;
            
        case AST_INDEXACAO:
            if (ast->dados.indexacao.array)
                ast->dados.indexacao.array = passePropagacaoConstantes(ast->dados.indexacao.array);
            if (ast->dados.indexacao.indice)
                ast->dados.indexacao.indice = passePropagacaoConstantes(ast->dados.indexacao.indice);
            return ast;
            
        case AST_DECL_FUNCAO:
            if (ast->dados.funcao.parametros)
                ast->dados.funcao.parametros = passePropagacaoConstantes(ast->dados.funcao.parametros);
            if (ast->dados.funcao.corpo)
                ast->dados.funcao.corpo = passePropagacaoConstantes(ast->dados.funcao.corpo);
            return ast;
            
        default:
            return ast;
    }
}


void imprimirEstatisticasOtimizacao(void) {
    printf("\n=== ESTATÍSTICAS DE OTIMIZAÇÃO ===\n");
    printf("Constant folding realizados: %d\n", stats_folding);
    printf("Propagações de constantes: %d\n", stats_propagacao);
    printf("Total de otimizações: %d\n", stats_folding + stats_propagacao);
    printf("===================================\n\n");
}
