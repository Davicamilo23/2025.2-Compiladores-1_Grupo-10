#include "ast.h"
#include "tabela.h"
#include <string.h>

char* duplicarString(const char *str) {
    if (!str) return NULL;

    size_t len = strlen(str);
    char *nova = (char*)malloc(len + 1);
    if (!nova) {
        fprintf(stderr, "[ERRO] Falha ao alocar memória em duplicarString()\n");
        exit(1); 
    }

    memcpy(nova, str, len + 1); 
    return nova;
}

// Criar nó literal inteiro
Ast* criarLiteralInt(int valor, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_LITERAL_INT;
    no->tipo_dado = TIPO_INT;
    no->linha = linha;
    no->dados.literal.valor_int = valor;
    
    return no;
}

// Criar nó literal float
Ast* criarLiteralFloat(float valor, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_LITERAL_FLOAT;
    no->tipo_dado = TIPO_FLOAT;
    no->linha = linha;
    no->dados.literal.valor_float = valor;
    
    return no;
}

// Criar nó literal char
Ast* criarLiteralChar(char valor, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_LITERAL_CHAR;
    no->tipo_dado = TIPO_CHAR;
    no->linha = linha;
    no->dados.literal.valor_char = valor;
    
    return no;
}

// Criar nó literal string
Ast* criarLiteralString(const char *valor, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_LITERAL_STRING;
    no->tipo_dado = TIPO_CHAR;  // strings são arrays de char
    no->linha = linha;
    no->dados.literal.valor_string = duplicarString(valor);
    
    return no;
}

// Criar nó identificador
Ast* criarIdentificador(const char *nome, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_IDENTIFICADOR;
    no->tipo_dado = TIPO_DESCONHECIDO;  // será resolvido no passo C
    no->linha = linha;
    no->dados.identificador.nome = duplicarString(nome);
    
    return no;
}

// Criar nó de declaração de variável
Ast* criarDeclaracaoVar(Tipo tipo, const char *nome, Ast *inicializador, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_DECL_VAR;
    no->tipo_dado = tipo;
    no->linha = linha;
    no->dados.declaracao.tipo = tipo;
    no->dados.declaracao.nome = duplicarString(nome);
    no->dados.declaracao.tamanho_array = 0;
    no->dados.declaracao.inicializador = inicializador;
    
    return no;
}

// Criar nó de declaração de array
Ast* criarDeclaracaoArray(Tipo tipo, const char *nome, int tamanho, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_DECL_ARRAY;
    no->tipo_dado = tipo;
    no->linha = linha;
    no->dados.declaracao.tipo = tipo;
    no->dados.declaracao.nome = duplicarString(nome);
    no->dados.declaracao.tamanho_array = tamanho;
    no->dados.declaracao.inicializador = NULL;
    
    return no;
}

// Criar nó de declaração de função
Ast* criarDeclaracaoFuncao(Tipo tipo_retorno, const char *nome, Ast *parametros, Ast *corpo, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_DECL_FUNCAO;
    no->tipo_dado = tipo_retorno;
    no->linha = linha;
    no->dados.funcao.tipo_retorno = tipo_retorno;
    no->dados.funcao.nome = duplicarString(nome);
    no->dados.funcao.parametros = parametros;
    no->dados.funcao.corpo = corpo;
    
    return no;
}

// Criar nó de operador binário
Ast* criarOpBinario(TipoOpBinario op, Ast *esquerda, Ast *direita, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_OP_BINARIO;
    no->tipo_dado = TIPO_DESCONHECIDO;  // será resolvido no passo C
    no->linha = linha;
    no->dados.op_binario.op = op;
    no->dados.op_binario.esquerda = esquerda;
    no->dados.op_binario.direita = direita;
    
    return no;
}

// Criar nó de operador unário
Ast* criarOpUnario(TipoOpUnario op, Ast *operando, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_OP_UNARIO;
    no->tipo_dado = TIPO_DESCONHECIDO;  // será resolvido no passo C
    no->linha = linha;
    no->dados.op_unario.op = op;
    no->dados.op_unario.operando = operando;
    
    return no;
}

// Criar nó de indexação
Ast* criarIndexacao(Ast *array, Ast *indice, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_INDEXACAO;
    no->tipo_dado = TIPO_DESCONHECIDO;  // será resolvido no passo C
    no->linha = linha;
    no->dados.indexacao.array = array;
    no->dados.indexacao.indice = indice;
    
    return no;
}

// Criar nó de chamada de função
Ast* criarChamadaFuncao(const char *nome, Ast *argumentos, int linha) {
    // ADICIONAR ESTAS LINHAS:
    if (nome == NULL) {
        fprintf(stderr, "ERRO: criarChamadaFuncao recebeu nome NULL (linha %d)\n", linha);
        nome = "unknown_function";
    }
    // FIM DA ADIÇÃO
    
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_CHAMADA_FUNCAO;
    no->tipo_dado = TIPO_DESCONHECIDO;
    no->linha = linha;
    no->dados.chamada.nome_funcao = duplicarString(nome);
    no->dados.chamada.argumentos = argumentos;
    
    return no;
}

// Criar nó de atribuição
Ast* criarAtribuicao(Ast *variavel, Ast *valor, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_ATRIBUICAO;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.atribuicao.variavel = variavel;
    no->dados.atribuicao.valor = valor;
    
    return no;
}

// Criar nó if/if-else
Ast* criarIf(Ast *condicao, Ast *bloco_then, Ast *bloco_else, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = bloco_else ? AST_IF_ELSE : AST_IF;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.if_stmt.condicao = condicao;
    no->dados.if_stmt.bloco_then = bloco_then;
    no->dados.if_stmt.bloco_else = bloco_else;
    
    return no;
}

// Criar nó while
Ast* criarWhile(Ast *condicao, Ast *corpo, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_WHILE;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.while_stmt.condicao = condicao;
    no->dados.while_stmt.corpo = corpo;
    
    return no;
}

// Criar nó for
Ast* criarFor(Ast *init, Ast *cond, Ast *incr, Ast *corpo, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_FOR;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.for_stmt.inicializacao = init;
    no->dados.for_stmt.condicao = cond;
    no->dados.for_stmt.incremento = incr;
    no->dados.for_stmt.corpo = corpo;
    
    return no;
}

// Criar nó return
Ast* criarReturn(Ast *expressao, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_RETURN;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.return_stmt.expressao = expressao;
    
    return no;
}

// Criar nó bloco
Ast* criarBloco(Ast *statements, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_BLOCO;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.bloco.statements = statements;
    
    return no;
}

// Criar nó de expressão como statement
Ast* criarExprStmt(Ast *expr, int linha) {
    fprintf(stderr, "\n[AST] 🧩 criarExprStmt chamado (linha %d)\n", linha);

    if (!expr) {
        fprintf(stderr, "⚠️ [AST] criarExprStmt recebeu expr = NULL (linha %d)\n", linha);
    } else {
        fprintf(stderr, "✅ [AST] criarExprStmt recebeu expr tipo = %d\n", expr->tipo);
    }

    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) {
        fprintf(stderr, "❌ [AST] Falha em calloc em criarExprStmt (linha %d)\n", linha);
        return NULL;
    }

    no->tipo = AST_EXPR_STMT;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.expr_stmt.expressao = expr;

    fprintf(stderr, "✨ [AST] AST_EXPR_STMT criado com expr @%p (linha %d)\n", (void*)expr, linha);

    return no;
}

// Criar nó programa (raiz)
Ast* criarPrograma(Ast *declaracoes, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_PROGRAMA;
    no->tipo_dado = TIPO_VOID;
    no->linha = linha;
    no->dados.bloco.statements = declaracoes;
    
    return no;
}

// Criar nó lista
Ast* criarLista(Ast *item, Ast *proximo) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_LISTA;
    no->tipo_dado = TIPO_VOID;
    no->dados.lista.item = item;
    no->dados.lista.proximo = proximo;
    
    return no;
}

// Criar nó parâmetro
Ast* criarParametro(Tipo tipo, const char *nome, int linha) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_PARAM;
    no->tipo_dado = tipo;
    no->linha = linha;
    no->dados.parametro.tipo = tipo;
    no->dados.parametro.nome = duplicarString(nome);
    
    return no;
}

// Criar nó vazio
Ast* criarVazio(void) {
    Ast *no = (Ast*)calloc(1, sizeof(Ast));
    if (!no) return NULL;
    
    no->tipo = AST_VAZIO;
    no->tipo_dado = TIPO_VOID;
    
    return no;
}

///Liberar memória da AST
void liberarAst(Ast *ast) {
    if (!ast) return;
    
    switch (ast->tipo) {
        case AST_LITERAL_STRING:
            free(ast->dados.literal.valor_string);
            break;
            
        case AST_IDENTIFICADOR:
            free(ast->dados.identificador.nome);
            break;
            
        case AST_DECL_VAR:
        case AST_DECL_ARRAY:
            free(ast->dados.declaracao.nome);
            liberarAst(ast->dados.declaracao.inicializador);
            break;
            
        case AST_DECL_FUNCAO:
            free(ast->dados.funcao.nome);
            liberarAst(ast->dados.funcao.parametros);
            liberarAst(ast->dados.funcao.corpo);
            break;
            
        case AST_OP_BINARIO:
            liberarAst(ast->dados.op_binario.esquerda);
            liberarAst(ast->dados.op_binario.direita);
            break;
            
        case AST_OP_UNARIO:
            liberarAst(ast->dados.op_unario.operando);
            break;
            
        case AST_ATRIBUICAO:
            liberarAst(ast->dados.atribuicao.variavel);
            liberarAst(ast->dados.atribuicao.valor);
            break;
            
        case AST_IF:
        case AST_IF_ELSE:
            liberarAst(ast->dados.if_stmt.condicao);
            liberarAst(ast->dados.if_stmt.bloco_then);
            liberarAst(ast->dados.if_stmt.bloco_else);
            break;
            
        case AST_WHILE:
            liberarAst(ast->dados.while_stmt.condicao);
            liberarAst(ast->dados.while_stmt.corpo);
            break;
            
        case AST_FOR:
            liberarAst(ast->dados.for_stmt.inicializacao);
            liberarAst(ast->dados.for_stmt.condicao);
            liberarAst(ast->dados.for_stmt.incremento);
            liberarAst(ast->dados.for_stmt.corpo);
            break;
            
        case AST_RETURN:
            liberarAst(ast->dados.return_stmt.expressao);
            break;

        case AST_BLOCO:
        case AST_PROGRAMA:
            liberarAst(ast->dados.bloco.statements);            
            break;

        case AST_CHAMADA_FUNCAO:
            free(ast->dados.chamada.nome_funcao);
            liberarAst(ast->dados.chamada.argumentos);
            break;
            
        case AST_INDEXACAO:
            liberarAst(ast->dados.indexacao.array);
            liberarAst(ast->dados.indexacao.indice);
            break;
            
        case AST_LISTA:
            liberarAst(ast->dados.lista.item);
            liberarAst(ast->dados.lista.proximo);
            break;
            
        case AST_PARAM:
            free(ast->dados.parametro.nome);
            break;

        case AST_EXPR_STMT:
            liberarAst(ast->dados.expr_stmt.expressao);
            break;

        default:
            break;
    }
    
    free(ast);
}


static void imprimirIndentacao(int prof) {
    for (int i = 0; i < prof; i++) printf("  ");
}

static const char* tipoNoParaString(TipoNoAST tipo) {
    switch (tipo) {
        case AST_DECL_VAR: return "DECL_VAR";
        case AST_DECL_ARRAY: return "DECL_ARRAY";
        case AST_DECL_FUNCAO: return "DECL_FUNCAO";
        case AST_LITERAL_INT: return "LITERAL_INT";
        case AST_LITERAL_FLOAT: return "LITERAL_FLOAT";
        case AST_LITERAL_CHAR: return "LITERAL_CHAR";
        case AST_LITERAL_STRING: return "LITERAL_STRING";
        case AST_IDENTIFICADOR: return "IDENTIFICADOR";
        case AST_OP_BINARIO: return "OP_BINARIO";
        case AST_OP_UNARIO: return "OP_UNARIO";
        case AST_INDEXACAO: return "INDEXACAO";
        case AST_CHAMADA_FUNCAO: return "CHAMADA_FUNCAO";
        case AST_ATRIBUICAO: return "ATRIBUICAO";
        case AST_IF: return "IF";
        case AST_IF_ELSE: return "IF_ELSE";
        case AST_WHILE: return "WHILE";
        case AST_FOR: return "FOR";
        case AST_RETURN: return "RETURN";
        case AST_BLOCO: return "BLOCO";
        case AST_EXPR_STMT: return "EXPR_STMT";
        case AST_PROGRAMA: return "PROGRAMA";
        case AST_LISTA: return "LISTA";
        case AST_PARAM: return "PARAM";
        case AST_VAZIO: return "VAZIO";
        default: return "DESCONHECIDO";
    }
}

void imprimirAst(Ast *ast, int prof) {
    if (!ast) return;
    
    imprimirIndentacao(prof);
    printf("%s", tipoNoParaString(ast->tipo));
    
    switch (ast->tipo) {
        case AST_LITERAL_INT:
            printf(" = %d", ast->dados.literal.valor_int);
            break;
        case AST_LITERAL_FLOAT:
            printf(" = %.2f", ast->dados.literal.valor_float);
            break;
        case AST_LITERAL_CHAR:
            printf(" = '%c'", ast->dados.literal.valor_char);
            break;
        case AST_LITERAL_STRING:
            printf(" = \"%s\"", ast->dados.literal.valor_string);
            break;
        case AST_IDENTIFICADOR:
            printf(" = %s", ast->dados.identificador.nome);
            break;
        case AST_DECL_VAR:
            printf(" %s %s", tipoParaString(ast->dados.declaracao.tipo), 
                   ast->dados.declaracao.nome);
            if (ast->dados.declaracao.inicializador) {
                printf(" =\n");
                imprimirAst(ast->dados.declaracao.inicializador, prof + 1);
            }
            break;
        case AST_DECL_ARRAY:
            printf(" %s %s[%d]", tipoParaString(ast->dados.declaracao.tipo),
                   ast->dados.declaracao.nome, ast->dados.declaracao.tamanho_array);
            break;
        case AST_DECL_FUNCAO:
            printf(" %s %s()\n", tipoParaString(ast->dados.funcao.tipo_retorno),
                   ast->dados.funcao.nome);
            imprimirAst(ast->dados.funcao.parametros, prof + 1);
            imprimirAst(ast->dados.funcao.corpo, prof + 1);
            return;
        default:
            break;
    }
    
    printf("\n");
    
    // Percorrer filhos recursivamente
    switch (ast->tipo) {
        case AST_OP_BINARIO:
            imprimirAst(ast->dados.op_binario.esquerda, prof + 1);
            imprimirAst(ast->dados.op_binario.direita, prof + 1);
            break;
        case AST_OP_UNARIO:
            imprimirAst(ast->dados.op_unario.operando, prof + 1);
            break;
        case AST_ATRIBUICAO:
            imprimirAst(ast->dados.atribuicao.variavel, prof + 1);
            imprimirAst(ast->dados.atribuicao.valor, prof + 1);
            break;
        case AST_IF:
        case AST_IF_ELSE:
            imprimirAst(ast->dados.if_stmt.condicao, prof + 1);
            imprimirAst(ast->dados.if_stmt.bloco_then, prof + 1);
            imprimirAst(ast->dados.if_stmt.bloco_else, prof + 1);
            break;
        case AST_WHILE:
            imprimirAst(ast->dados.while_stmt.condicao, prof + 1);
            imprimirAst(ast->dados.while_stmt.corpo, prof + 1);
            break;
        case AST_FOR:
            imprimirAst(ast->dados.for_stmt.inicializacao, prof + 1);
            imprimirAst(ast->dados.for_stmt.condicao, prof + 1);
            imprimirAst(ast->dados.for_stmt.incremento, prof + 1);
            imprimirAst(ast->dados.for_stmt.corpo, prof + 1);
            break;
        case AST_RETURN:
            imprimirAst(ast->dados.return_stmt.expressao, prof + 1);
            break;
        case AST_BLOCO:
        case AST_PROGRAMA:
            imprimirAst(ast->dados.bloco.statements, prof + 1); 
            break;
        case AST_CHAMADA_FUNCAO:
            imprimirAst(ast->dados.chamada.argumentos, prof + 1);
            break;
        case AST_INDEXACAO:
            imprimirAst(ast->dados.indexacao.array, prof + 1);
            imprimirAst(ast->dados.indexacao.indice, prof + 1);
            break;
        case AST_LISTA:
            imprimirAst(ast->dados.lista.item, prof);
            imprimirAst(ast->dados.lista.proximo, prof);
            break;
        default:
            break;
    }
}

static int escopo_atual = 0;

// Passo B: Popular tabela de símbolos
void passoDeclararSimbolos(Ast *ast) {
    if (!ast) return;
    
    ast->escopo_nivel = escopo_atual;
    
    switch (ast->tipo) {
        case AST_DECL_VAR:
            // Inserir variável na tabela
            inserirSimboloTipado(ast->dados.declaracao.nome, 
                               CATEGORIA_VARIAVEL,
                               ast->dados.declaracao.tipo,
                               0);
            // Se tem inicializador, processar
            if (ast->dados.declaracao.inicializador) {
                passoDeclararSimbolos(ast->dados.declaracao.inicializador);
                marcarInicializada(ast->dados.declaracao.nome);
            }
            break;
            
        case AST_DECL_ARRAY:
            // Inserir array na tabela
            inserirSimboloTipado(ast->dados.declaracao.nome,
                               CATEGORIA_ARRAY,
                               ast->dados.declaracao.tipo,
                               0);
            break;
            
        case AST_DECL_FUNCAO:
            // Inserir função na tabela
            inserirSimboloTipado(ast->dados.funcao.nome,
                               CATEGORIA_FUNCAO,
                               ast->dados.funcao.tipo_retorno,
                               0);
            // Processar parâmetros em novo escopo
            escopo_atual++;
            passoDeclararSimbolos(ast->dados.funcao.parametros);
            passoDeclararSimbolos(ast->dados.funcao.corpo);
            escopo_atual--;
            break;
            
        case AST_PARAM:
            // Inserir parâmetro na tabela (como variável)
            inserirSimboloTipado(ast->dados.parametro.nome,
                               CATEGORIA_VARIAVEL,
                               ast->dados.parametro.tipo,
                               0);
            marcarInicializada(ast->dados.parametro.nome);
            break;
            
        case AST_BLOCO:
            // Novo escopo para blocos (mas não incrementamos sempre - 
            // apenas se for bloco de função ou controle)
            passoDeclararSimbolos(ast->dados.bloco.statements);
            break;
            
        case AST_LISTA:
            passoDeclararSimbolos(ast->dados.lista.item);
            passoDeclararSimbolos(ast->dados.lista.proximo);
            break;
            
        case AST_IF:
        case AST_IF_ELSE:
            passoDeclararSimbolos(ast->dados.if_stmt.condicao);
            passoDeclararSimbolos(ast->dados.if_stmt.bloco_then);
            passoDeclararSimbolos(ast->dados.if_stmt.bloco_else);
            break;
            
        case AST_WHILE:
            passoDeclararSimbolos(ast->dados.while_stmt.condicao);
            passoDeclararSimbolos(ast->dados.while_stmt.corpo);
            break;
            
        case AST_FOR:
            passoDeclararSimbolos(ast->dados.for_stmt.inicializacao);
            passoDeclararSimbolos(ast->dados.for_stmt.condicao);
            passoDeclararSimbolos(ast->dados.for_stmt.incremento);
            passoDeclararSimbolos(ast->dados.for_stmt.corpo);
            break;
            
        case AST_ATRIBUICAO:
            passoDeclararSimbolos(ast->dados.atribuicao.variavel);
            passoDeclararSimbolos(ast->dados.atribuicao.valor);
            // Marcar variável como inicializada após atribuição
            if (ast->dados.atribuicao.variavel && 
                ast->dados.atribuicao.variavel->tipo == AST_IDENTIFICADOR) {
                marcarInicializada(ast->dados.atribuicao.variavel->dados.identificador.nome);
            }
            break;
            
        case AST_OP_BINARIO:
            passoDeclararSimbolos(ast->dados.op_binario.esquerda);
            passoDeclararSimbolos(ast->dados.op_binario.direita);
            break;
            
        case AST_OP_UNARIO:
            passoDeclararSimbolos(ast->dados.op_unario.operando);
            break;
            
        case AST_RETURN:
            passoDeclararSimbolos(ast->dados.return_stmt.expressao);
            break;
            
        case AST_CHAMADA_FUNCAO:
            passoDeclararSimbolos(ast->dados.chamada.argumentos);
            break;
            
        case AST_INDEXACAO:
            passoDeclararSimbolos(ast->dados.indexacao.array);
            passoDeclararSimbolos(ast->dados.indexacao.indice);
            break;
            
        case AST_EXPR_STMT:
            passoDeclararSimbolos(ast->dados.expr_stmt.expressao);
            break;

        case AST_PROGRAMA:
            passoDeclararSimbolos(ast->dados.bloco.statements);
            break;

            
        default:
            // Literais, identificadores, etc. não fazem nada aqui
            break;
    }
}

//PASSO C: CHECAGEM SEMÂNTICA
static Tipo resolverTipoExpressao(Ast *ast);

// Promover tipos (int + float = float)
static Tipo promoverTipos(Tipo t1, Tipo t2) {
    if (t1 == TIPO_FLOAT || t2 == TIPO_FLOAT) return TIPO_FLOAT;
    if (t1 == TIPO_INT || t2 == TIPO_INT) return TIPO_INT;
    if (t1 == TIPO_CHAR || t2 == TIPO_CHAR) return TIPO_CHAR;
    return TIPO_DESCONHECIDO;
}

// Resolver tipo de uma expressão
static Tipo resolverTipoExpressao(Ast *ast) {
    if (!ast) return TIPO_VOID;
    
    switch (ast->tipo) {
        case AST_LITERAL_INT:
            return TIPO_INT;
        case AST_LITERAL_FLOAT:
            return TIPO_FLOAT;
        case AST_LITERAL_CHAR:
        case AST_LITERAL_STRING:
            return TIPO_CHAR;
            
        case AST_IDENTIFICADOR: {
            Simbolo *s = buscarSimbolo(ast->dados.identificador.nome);
            if (!s) {
                fprintf(stderr, "Erro semântico (linha %d): Variável '%s' não declarada.\n",
                        ast->linha, ast->dados.identificador.nome);
                return TIPO_DESCONHECIDO;
            }
            if (!s->inicializada) {
                fprintf(stderr, "Aviso (linha %d): Variável '%s' pode não ter sido inicializada.\n",
                        ast->linha, ast->dados.identificador.nome);
            }
            return s->tipo;
        }
            
        case AST_OP_BINARIO: {
            Tipo t_esq = resolverTipoExpressao(ast->dados.op_binario.esquerda);
            Tipo t_dir = resolverTipoExpressao(ast->dados.op_binario.direita);
            
            // Operadores relacionais e lógicos retornam int (booleano)
            if (ast->dados.op_binario.op >= OP_EQ && ast->dados.op_binario.op <= OP_OR) {
                return TIPO_INT;
            }
            
            // Módulo só funciona com int
            if (ast->dados.op_binario.op == OP_MOD) {
                if (t_esq != TIPO_INT || t_dir != TIPO_INT) {
                    fprintf(stderr, "Erro semântico (linha %d): Operador %% requer operandos inteiros.\n",
                            ast->linha);
                }
                return TIPO_INT;
            }
            
            return promoverTipos(t_esq, t_dir);
        }
            
        case AST_OP_UNARIO:
            return resolverTipoExpressao(ast->dados.op_unario.operando);
            
        case AST_INDEXACAO: {
            Tipo t_array = resolverTipoExpressao(ast->dados.indexacao.array);
            Tipo t_indice = resolverTipoExpressao(ast->dados.indexacao.indice);
            
            // Verificar se índice é inteiro
            if (t_indice != TIPO_INT) {
                fprintf(stderr, "Erro semântico (linha %d): Índice de array deve ser inteiro.\n",
                        ast->linha);
            }
            
            return t_array;
        }
            
        case AST_CHAMADA_FUNCAO: {
            Simbolo *s = buscarSimbolo(ast->dados.chamada.nome_funcao);
            if (!s) {
                fprintf(stderr, "Erro semântico (linha %d): Função '%s' não declarada.\n",
                        ast->linha, ast->dados.chamada.nome_funcao);
                return TIPO_DESCONHECIDO;
            }
            return s->tipo;
        }
            
        default:
            return TIPO_VOID;
    }
}

// Passo C: Checagem semântica
void passoChecagemSemantica(Ast *ast) {
    if (!ast) return;
    
    switch (ast->tipo) {
        case AST_ATRIBUICAO: {
            // Checar tipos
            Tipo t_var = resolverTipoExpressao(ast->dados.atribuicao.variavel);
            Tipo t_val = resolverTipoExpressao(ast->dados.atribuicao.valor);
            
            if (t_var != t_val && t_var != TIPO_DESCONHECIDO && t_val != TIPO_DESCONHECIDO) {
                // Permitir int <-> float com aviso
                if ((t_var == TIPO_INT && t_val == TIPO_FLOAT) ||
                    (t_var == TIPO_FLOAT && t_val == TIPO_INT)) {
                    fprintf(stderr, "Aviso (linha %d): Conversão implícita entre int e float.\n",
                            ast->linha);
                } else {
                    fprintf(stderr, "Erro semântico (linha %d): Atribuição incompatível entre '%s' e '%s'.\n",
                            ast->linha, tipoParaString(t_var), tipoParaString(t_val));
                }
            }
            
            passoChecagemSemantica(ast->dados.atribuicao.variavel);
            passoChecagemSemantica(ast->dados.atribuicao.valor);
            break;
        }
            
        case AST_DECL_VAR:
            if (ast->dados.declaracao.inicializador) {
                Tipo t_init = resolverTipoExpressao(ast->dados.declaracao.inicializador);
                if (t_init != ast->dados.declaracao.tipo && 
                    t_init != TIPO_DESCONHECIDO) {
                    fprintf(stderr, "Aviso (linha %d): Inicialização com tipo diferente.\n",
                            ast->linha);
                }
                passoChecagemSemantica(ast->dados.declaracao.inicializador);
            }
            break;
            
        case AST_OP_BINARIO:
            ast->tipo_dado = resolverTipoExpressao(ast);
            passoChecagemSemantica(ast->dados.op_binario.esquerda);
            passoChecagemSemantica(ast->dados.op_binario.direita);
            break;
            
        case AST_OP_UNARIO:
            ast->tipo_dado = resolverTipoExpressao(ast);
            passoChecagemSemantica(ast->dados.op_unario.operando);
            break;
            
        case AST_IDENTIFICADOR:
            ast->tipo_dado = resolverTipoExpressao(ast);
            break;
            
        case AST_INDEXACAO:
            ast->tipo_dado = resolverTipoExpressao(ast);
            passoChecagemSemantica(ast->dados.indexacao.array);
            passoChecagemSemantica(ast->dados.indexacao.indice);
            break;
            
        case AST_CHAMADA_FUNCAO:
            ast->tipo_dado = resolverTipoExpressao(ast);
            passoChecagemSemantica(ast->dados.chamada.argumentos);
            break;
            
        case AST_IF:
        case AST_IF_ELSE:
            passoChecagemSemantica(ast->dados.if_stmt.condicao);
            passoChecagemSemantica(ast->dados.if_stmt.bloco_then);
            passoChecagemSemantica(ast->dados.if_stmt.bloco_else);
            break;
            
        case AST_WHILE:
            passoChecagemSemantica(ast->dados.while_stmt.condicao);
            passoChecagemSemantica(ast->dados.while_stmt.corpo);
            break;
            
        case AST_FOR:
            passoChecagemSemantica(ast->dados.for_stmt.inicializacao);
            passoChecagemSemantica(ast->dados.for_stmt.condicao);
            passoChecagemSemantica(ast->dados.for_stmt.incremento);
            passoChecagemSemantica(ast->dados.for_stmt.corpo);
            break;
            
        case AST_RETURN:
            passoChecagemSemantica(ast->dados.return_stmt.expressao);
            break;
            
        case AST_DECL_FUNCAO:
            passoChecagemSemantica(ast->dados.funcao.parametros);
            passoChecagemSemantica(ast->dados.funcao.corpo);
            break;
            
        case AST_BLOCO:
        case AST_EXPR_STMT:
            passoChecagemSemantica(ast->dados.expr_stmt.expressao);
            break;

        case AST_PROGRAMA:
            passoChecagemSemantica(ast->dados.bloco.statements);
            break;

        case AST_LISTA:
            passoChecagemSemantica(ast->dados.lista.item);
            passoChecagemSemantica(ast->dados.lista.proximo);
            break;
            
        default:
            break;
    }
}

Ast* adicionarDeclaracao(Ast* programa, Ast* nova_decl) {
    if (!programa)
        return criarPrograma(nova_decl, 0);

    // Se o programa é uma lista de declarações, só encadeia
    if (programa->tipo == AST_LISTA)
        return criarLista(programa, nova_decl);

    // Se é um programa raiz, encadeia o novo nó após o existente
    if (programa->tipo == AST_PROGRAMA)
        return criarLista(programa, nova_decl);

    // Caso contrário, cria uma lista nova
    return criarLista(programa, nova_decl);
}
