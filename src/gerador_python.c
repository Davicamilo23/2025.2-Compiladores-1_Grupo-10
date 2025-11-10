/* gerador_python.c
 * Gerador de código Python a partir da AST
 * VERSÃO CORRIGIDA - Ana
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela_simbolos/ast.h"
#include "tabela_simbolos/tabela.h"

static FILE *saida = NULL;
static int indent = 0;

// ==========================================
// AUXILIARES
// ==========================================

static void printIndent() {
    for (int i = 0; i < indent; i++) {
        fprintf(saida, "    ");
    }
}

static const char* opBinStr(TipoOpBinario op) {
    switch (op) {
        case OP_MAIS:  return " + ";
        case OP_MENOS: return " - ";
        case OP_MULT:  return " * ";
        case OP_DIV:   return " / ";
        case OP_MOD:   return " % ";
        case OP_EQ:    return " == ";
        case OP_NE:    return " != ";
        case OP_LT:    return " < ";
        case OP_LE:    return " <= ";
        case OP_GT:    return " > ";
        case OP_GE:    return " >= ";
        case OP_AND:   return " and ";
        case OP_OR:    return " or ";
        default:       return " ??? ";
    }
}

static const char* opUnStr(TipoOpUnario op) {
    switch (op) {
        case OP_UN_MENOS: return "-";
        case OP_UN_NOT:   return "not ";
        default:          return "";
    }
}

// ==========================================
// GERAÇÃO DE EXPRESSÕES
// ==========================================

void gerarExpr(Ast *ast);

void gerarExpr(Ast *ast) {
    if (!ast) return;
    
    switch (ast->tipo) {
        case AST_LITERAL_INT:
            fprintf(saida, "%d", ast->dados.literal.valor_int);
            break;
            
        case AST_LITERAL_FLOAT:
            fprintf(saida, "%.2f", ast->dados.literal.valor_float);
            break;
            
        case AST_LITERAL_CHAR:
            fprintf(saida, "'%c'", ast->dados.literal.valor_char);
            break;
            
        case AST_LITERAL_STRING:
            fprintf(saida, "%s", ast->dados.literal.valor_string);
            break;
            
        case AST_IDENTIFICADOR:
            fprintf(saida, "%s", ast->dados.identificador.nome);
            break;
            
        case AST_OP_BINARIO:
            fprintf(saida, "(");
            gerarExpr(ast->dados.op_binario.esquerda);
            fprintf(saida, "%s", opBinStr(ast->dados.op_binario.op));
            gerarExpr(ast->dados.op_binario.direita);
            fprintf(saida, ")");
            break;
            
        case AST_OP_UNARIO:
            fprintf(saida, "%s", opUnStr(ast->dados.op_unario.op));
            gerarExpr(ast->dados.op_unario.operando);
            break;
            
        case AST_INDEXACAO:
            gerarExpr(ast->dados.indexacao.array);
            fprintf(saida, "[");
            gerarExpr(ast->dados.indexacao.indice);
            fprintf(saida, "]");
            break;
            
        case AST_CHAMADA_FUNCAO: {
            // printf → print
            if (strcmp(ast->dados.chamada.nome_funcao, "printf") == 0) {
                fprintf(saida, "print(");
                
                // Argumentos
                Ast *args = ast->dados.chamada.argumentos;
                int primeiro = 1;
                while (args && args->tipo == AST_LISTA) {
                    if (!primeiro) fprintf(saida, ", ");
                    if (args->dados.lista.item) {
                        gerarExpr(args->dados.lista.item);
                    }
                    primeiro = 0;
                    args = args->dados.lista.proximo;
                }
                fprintf(saida, ", end='')");  
            } else {
                // Outras funções
                fprintf(saida, "%s(", ast->dados.chamada.nome_funcao);
                
                Ast *args = ast->dados.chamada.argumentos;
                int primeiro = 1;
                while (args && args->tipo == AST_LISTA) {
                    if (!primeiro) fprintf(saida, ", ");
                    if (args->dados.lista.item) {
                        gerarExpr(args->dados.lista.item);
                    }
                    primeiro = 0;
                    args = args->dados.lista.proximo;
                }
                fprintf(saida, ")");
            }
            break;
        }
            
        default:
            break;
    }
}

// ==========================================
// GERAÇÃO DE STATEMENTS
// ==========================================

void gerarStmt(Ast *ast);

void gerarStmt(Ast *ast) {
    if (!ast) return;
    
    switch (ast->tipo) {
        case AST_DECL_VAR:
            printIndent();
            fprintf(saida, "%s = ", ast->dados.declaracao.nome);
            
            if (ast->dados.declaracao.inicializador) {
                gerarExpr(ast->dados.declaracao.inicializador);
            } else {
                fprintf(saida, "None");
            }
            fprintf(saida, "\n");
            break;
            
        case AST_DECL_ARRAY:
            printIndent();
            fprintf(saida, "%s = [None] * %d\n", 
                    ast->dados.declaracao.nome,
                    ast->dados.declaracao.tamanho_array);
            break;
            
        case AST_ATRIBUICAO:
            printIndent();
            gerarExpr(ast->dados.atribuicao.variavel);
            fprintf(saida, " = ");
            gerarExpr(ast->dados.atribuicao.valor);
            fprintf(saida, "\n");
            break;
            
        case AST_IF:
        case AST_IF_ELSE:
            printIndent();
            fprintf(saida, "if ");
            gerarExpr(ast->dados.if_stmt.condicao);
            fprintf(saida, ":\n");
            
            indent++;
            gerarStmt(ast->dados.if_stmt.bloco_then);
            indent--;
            
            if (ast->dados.if_stmt.bloco_else) {
                printIndent();
                fprintf(saida, "else:\n");
                indent++;
                gerarStmt(ast->dados.if_stmt.bloco_else);
                indent--;
            }
            break;
            
        case AST_WHILE:
            printIndent();
            fprintf(saida, "while ");
            gerarExpr(ast->dados.while_stmt.condicao);
            fprintf(saida, ":\n");
            
            indent++;
            gerarStmt(ast->dados.while_stmt.corpo);
            indent--;
            break;
            
        case AST_FOR: {
            printIndent();
            fprintf(saida, "# for convertido para while\n");
            
            if (ast->dados.for_stmt.inicializacao) {
                gerarStmt(ast->dados.for_stmt.inicializacao);
            }
            
            printIndent();
            fprintf(saida, "while ");
            if (ast->dados.for_stmt.condicao) {
                gerarExpr(ast->dados.for_stmt.condicao);
            } else {
                fprintf(saida, "True");
            }
            fprintf(saida, ":\n");
            
            indent++;
            gerarStmt(ast->dados.for_stmt.corpo);
            
            if (ast->dados.for_stmt.incremento) {
                printIndent();
                gerarExpr(ast->dados.for_stmt.incremento);
                fprintf(saida, "\n");
            }
            
            indent--;
            break;
        }
            
        case AST_RETURN:
            printIndent();
            fprintf(saida, "return");
            if (ast->dados.return_stmt.expressao) {
                fprintf(saida, " ");
                gerarExpr(ast->dados.return_stmt.expressao);
            }
            fprintf(saida, "\n");
            break;
            
        case AST_EXPR_STMT:
            printIndent();
            if (ast->dados.expr_stmt.expressao) {
                gerarExpr(ast->dados.expr_stmt.expressao);
            }
            fprintf(saida, "\n");
            break;

            
        case AST_BLOCO: {
            // Percorrer todos os statements do bloco
            Ast *stmt = ast->dados.bloco.statements;
            
            // Se for uma lista, percorrer todos
            while (stmt) {
                if (stmt->tipo == AST_LISTA) {
                    if (stmt->dados.lista.item) {
                        gerarStmt(stmt->dados.lista.item);
                    }
                    stmt = stmt->dados.lista.proximo;
                } else {
                    // Não é lista, gerar direto e sair
                    gerarStmt(stmt);
                    break;
                }
            }
            break;
        }
            
        case AST_LISTA: {
            // Percorrer toda a lista
            Ast *atual = ast;
            while (atual && atual->tipo == AST_LISTA) {
                if (atual->dados.lista.item) {
                    gerarStmt(atual->dados.lista.item);
                }
                atual = atual->dados.lista.proximo;
            }
            // Se sobrou algo que não é lista, gerar
            if (atual) {
                gerarStmt(atual);
            }
            break;
        }
            
        case AST_VAZIO:
            printIndent();
            fprintf(saida, "pass\n");
            break;
            
        default:
            break;
    }
}

// ==========================================
// GERAÇÃO DE FUNÇÕES
// ==========================================

void gerarFuncao(Ast *ast) {
    if (!ast || ast->tipo != AST_DECL_FUNCAO) return;

    fprintf(saida, "def %s(", ast->dados.funcao.nome);

    // --- Parâmetros ---
    Ast *params = ast->dados.funcao.parametros;
    int primeiro = 1;

    if (params) {
        if (params->tipo == AST_PARAM) {
            fprintf(saida, "%s", params->dados.parametro.nome);
        } else if (params->tipo == AST_LISTA) {
            while (params) {
                Ast *param = params->dados.lista.item;
                if (param && param->tipo == AST_PARAM) {
                    if (!primeiro) fprintf(saida, ", ");
                    fprintf(saida, "%s", param->dados.parametro.nome);
                    primeiro = 0;
                }
                params = params->dados.lista.proximo;
            }
        }
    }

    fprintf(saida, "):\n");

    // --- Corpo ---
    indent++;

    if (ast->dados.funcao.corpo) {
        gerarStmt(ast->dados.funcao.corpo);
    } else {
        printIndent();
        fprintf(saida, "pass\n");
    }

    indent--;
    fprintf(saida, "\n");
}

// ==========================================
// GERAÇÃO DO PROGRAMA COMPLETO
// ==========================================

void gerarPrograma(Ast *ast) {
    if (!ast) return;

    // Se for PROGRAMA, pega os statements
    if (ast->tipo == AST_PROGRAMA) {
        ast = ast->dados.bloco.statements;
    }

    // Percorrer todas as declarações (funções, variáveis globais, etc)
    while (ast) {
        Ast *item = NULL;

        if (ast->tipo == AST_LISTA) {
            item = ast->dados.lista.item;
        } else {
            item = ast;
        }

        if (item) {
            if (item->tipo == AST_DECL_FUNCAO) {
                gerarFuncao(item);
            } else {
                gerarStmt(item);
            }
        }

        // Avançar só se for lista
        if (ast->tipo == AST_LISTA) {
            ast = ast->dados.lista.proximo;
        } else {
            break;
        }
    }

    // Executar main automaticamente
    fprintf(saida, "\n# Executar main se existir\n");
    fprintf(saida, "if __name__ == '__main__':\n");
    fprintf(saida, "    if 'main' in dir():\n");
    fprintf(saida, "        main()\n");
}

// ==========================================
// FUNÇÃO PRINCIPAL
// ==========================================

void gerarCodigoPython(Ast *ast_raiz, const char *arquivo_saida) {
    if (!ast_raiz) {
        fprintf(stderr, "Erro: AST vazia!\n");
        return;
    }
    
    if (arquivo_saida) {
        saida = fopen(arquivo_saida, "w");
        if (!saida) {
            fprintf(stderr, "Erro ao abrir arquivo: %s\n", arquivo_saida);
            return;
        }
    } else {
        saida = stdout;
    }
    
    fprintf(saida, "#!/usr/bin/env python3\n");
    fprintf(saida, "# Código gerado automaticamente\n\n");
    
    indent = 0;
    gerarPrograma(ast_raiz);
    
    if (arquivo_saida) {
        fclose(saida);
        printf("✅ Código Python gerado: %s\n", arquivo_saida);
    }
}