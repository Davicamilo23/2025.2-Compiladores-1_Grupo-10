#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>

// Tipos de nós da AST
typedef enum {
    // Declarações
    AST_DECL_VAR,          // Declaração de variável: int x;
    AST_DECL_ARRAY,        // Declaração de array: int a[10];
    AST_DECL_FUNCAO,       // Declaração de função
    
    // Expressões
    AST_LITERAL_INT,       // Literal inteiro: 42
    AST_LITERAL_FLOAT,     // Literal float: 3.14
    AST_LITERAL_CHAR,      // Literal char: 'a'
    AST_LITERAL_STRING,    // Literal string: "hello"
    AST_IDENTIFICADOR,     // Identificador: x, y, funcao
    AST_OP_BINARIO,        // Operador binário: +, -, *, /, etc.
    AST_OP_UNARIO,         // Operador unário: -, !, &, *
    AST_INDEXACAO,         // Indexação de array: a[i]
    AST_CHAMADA_FUNCAO,    // Chamada de função: func(a, b)
    
    // Comandos
    AST_ATRIBUICAO,        // Atribuição: x = expr
    AST_IF,                // if (cond) stmt
    AST_IF_ELSE,           // if (cond) stmt1 else stmt2
    AST_WHILE,             // while (cond) stmt
    AST_FOR,               // for (init; cond; incr) stmt
    AST_RETURN,            // return expr;
    AST_BLOCO,             // { stmts }
    AST_EXPR_STMT,         // Expressão como statement
    
    // Estrutural
    AST_PROGRAMA,          // Nó raiz
    AST_LISTA,             // Lista de nós (statements, declarações, etc.)
    AST_PARAM,             // Parâmetro de função
    AST_VAZIO              // Nó vazio
} TipoNoAST;

// Tipos de operadores binários
typedef enum {
    OP_MAIS,      // +
    OP_MENOS,     // -
    OP_MULT,      // *
    OP_DIV,       // /
    OP_MOD,       // %
    OP_EQ,        // ==
    OP_NE,        // !=
    OP_LT,        // <
    OP_LE,        // <=
    OP_GT,        // >
    OP_GE,        // >=
    OP_AND,       // &&
    OP_OR         // ||
} TipoOpBinario;

// Tipos de operadores unários
typedef enum {
    OP_UN_MENOS,     // -expr
    OP_UN_NOT,       // !expr
    OP_UN_ADDR,      // &expr (endereço)
    OP_UN_DEREF      // *expr (desreferência)
} TipoOpUnario;

// Tipos de dados (forward declaration - já definido em tabela.h)
typedef enum {
    TIPO_INT,
    TIPO_FLOAT,
    TIPO_CHAR,
    TIPO_VOID,
    TIPO_DESCONHECIDO
} Tipo;

// Estrutura do nó da AST
typedef struct Ast {
    TipoNoAST tipo;           // Tipo do nó
    
    // Informações semânticas (populadas nos passes)
    Tipo tipo_dado;           // Tipo de dado da expressão/variável
    int escopo_nivel;         // Nível de escopo (0=global, 1=função, 2=bloco interno...)
    int linha;                // Linha do código fonte
    
    // Dados específicos do nó
    union {
        // Para literais
        struct {
            union {
                int valor_int;
                float valor_float;
                char valor_char;
                char *valor_string;
            };
        } literal;
        
        // Para identificadores
        struct {
            char *nome;
        } identificador;
        
        // Para declarações de variável/array
        struct {
            Tipo tipo;
            char *nome;
            int tamanho_array;     // 0 se não for array
            struct Ast *inicializador;  // NULL se não inicializada
        } declaracao;
        
        // Para operadores binários
        struct {
            TipoOpBinario op;
            struct Ast *esquerda;
            struct Ast *direita;
        } op_binario;
        
        // Para operadores unários
        struct {
            TipoOpUnario op;
            struct Ast *operando;
        } op_unario;
        
        // Para atribuição
        struct {
            struct Ast *variavel;   // lado esquerdo
            struct Ast *valor;      // lado direito
        } atribuicao;
        
        // Para if/if-else
        struct {
            struct Ast *condicao;
            struct Ast *bloco_then;
            struct Ast *bloco_else; // NULL se não houver else
        } if_stmt;
        
        // Para while
        struct {
            struct Ast *condicao;
            struct Ast *corpo;
        } while_stmt;
        
        // Para for
        struct {
            struct Ast *inicializacao;
            struct Ast *condicao;
            struct Ast *incremento;
            struct Ast *corpo;
        } for_stmt;
        
        // Para return
        struct {
            struct Ast *expressao;  // NULL para return vazio
        } return_stmt;
        
        // Para bloco
        struct {
            struct Ast *statements; // Lista de statements
        } bloco;
        
        // Para chamada de função
        struct {
            char *nome_funcao;
            struct Ast *argumentos;  // Lista de argumentos
        } chamada;
        
        // Para indexação de array
        struct {
            struct Ast *array;
            struct Ast *indice;
        } indexacao;
        
        // Para declaração de função
        struct {
            Tipo tipo_retorno;
            char *nome;
            struct Ast *parametros;  // Lista de parâmetros
            struct Ast *corpo;
        } funcao;
        
        // Para listas
        struct {
            struct Ast *item;
            struct Ast *proximo;
        } lista;
        
        // Para parâmetros
        struct {
            Tipo tipo;
            char *nome;
        } parametro;
        
    } dados;
    
} Ast;

// Criar nó literal
Ast* criarLiteralInt(int valor, int linha);
Ast* criarLiteralFloat(float valor, int linha);
Ast* criarLiteralChar(char valor, int linha);
Ast* criarLiteralString(const char *valor, int linha);

// Criar nó identificador
Ast* criarIdentificador(const char *nome, int linha);

// Criar nó de declaração
Ast* criarDeclaracaoVar(Tipo tipo, const char *nome, Ast *inicializador, int linha);
Ast* criarDeclaracaoArray(Tipo tipo, const char *nome, int tamanho, int linha);
Ast* criarDeclaracaoFuncao(Tipo tipo_retorno, const char *nome, Ast *parametros, Ast *corpo, int linha);

// Criar nó de expressão
Ast* criarOpBinario(TipoOpBinario op, Ast *esquerda, Ast *direita, int linha);
Ast* criarOpUnario(TipoOpUnario op, Ast *operando, int linha);
Ast* criarIndexacao(Ast *array, Ast *indice, int linha);
Ast* criarChamadaFuncao(const char *nome, Ast *argumentos, int linha);

// Criar nó de comando
Ast* criarAtribuicao(Ast *variavel, Ast *valor, int linha);
Ast* criarIf(Ast *condicao, Ast *bloco_then, Ast *bloco_else, int linha);
Ast* criarWhile(Ast *condicao, Ast *corpo, int linha);
Ast* criarFor(Ast *init, Ast *cond, Ast *incr, Ast *corpo, int linha);
Ast* criarReturn(Ast *expressao, int linha);
Ast* criarBloco(Ast *statements, int linha);
Ast* criarExprStmt(Ast *expr, int linha);

// Criar nó estrutural
Ast* criarPrograma(Ast *declaracoes, int linha);
Ast* criarLista(Ast *item, Ast *proximo);
Ast* criarParametro(Tipo tipo, const char *nome, int linha);
Ast* criarVazio(void);

// Liberar memória da AST
void liberarAst(Ast *ast);

// Imprimir AST (debug)
void imprimirAst(Ast *ast, int profundidade);
//Passos do compilador relacionados à AST
// Passo A: Construção da AST (feito pelo parser via ações semânticas)

// Passo B: Declarações e escopos
// Percorre a AST, abre/fecha escopos, insere símbolos na tabela
// Detecta redeclarações
void passoDeclararSimbolos(Ast *ast);

// Passo C: Checagem semântica
// Percorre a AST, tipa expressões, verifica compatibilidade
// Detecta uso antes de declaração, incompatibilidade de tipos
void passoChecagemSemantica(Ast *ast);

#endif // AST_H
