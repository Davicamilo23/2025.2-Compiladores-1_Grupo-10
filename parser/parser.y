%define parse.error detailed
%glr-parser

%code requires {
  #include "../src/tabela_simbolos/tipos.h"
  typedef struct Ast Ast; 
}

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "../src/tabela_simbolos/tabela.h"
  #include "../src/tabela_simbolos/ast.h"
  Ast* adicionarDeclaracao(Ast* programa, Ast* nova_decl);

  int yylex(void);
  int ptr_level_atual = 0;

  void yyerror(const char* s);

  extern int yylineno;
  extern char *ultimo_token;
  extern char *ultimo_lexema;
  extern Ast *ast_raiz;

  static void show_decl(const char* type, const char* name, int ptr_level) {
    printf("[DECL] %s %s (ptr_level=%d)\n", type, name, ptr_level);
  }

  static Tipo tipo_atual = TIPO_DESCONHECIDO;
  
  static int tiposCompativeis(Tipo tipo1, Tipo tipo2) {
    if (tipo1 == tipo2) return 1;
    if ((tipo1 == TIPO_INT && tipo2 == TIPO_FLOAT) ||
        (tipo1 == TIPO_FLOAT && tipo2 == TIPO_INT)) {
        printf("Aviso: Conversão implícita entre int e float.\n");
        return 1;
    }
    return 0;
  }
%}

%union {
  int    ival;
  char*  sval;
  int    n;
  Tipo   tipo;
  char*  nome_var;
  Ast*   ast;
}

%token T_INT T_CHAR T_VOID T_NULL T_FLOAT T_STATIC

%token IF ELSE WHILE FOR RETURN
%token ANDAND OROR NOT
%token EQ NE LT LE GT GE
%token AMP STAR PLUS MINUS SLASH PERCENT
%token ASSIGN
%token PLUSEQ MINUSEQ STAREQ SLASHEQ PERCENTEQ
%token DOT ARROW
%token COMMA SEMI COLON
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token <ival> ICONST
%token <sval> FCONST SCONST IDENT
%token BADCHAR

%left OROR
%left ANDAND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR SLASH PERCENT
%right NOT
%right UAMP USTAR UMINUS
%right ASSIGN PLUSEQ MINUSEQ STAREQ SLASHEQ PERCENTEQ

%type <n>    pointer_opt
%type <nome_var> declarator

%type <tipo> expression assignment_expression primary_expression
%type <tipo> postfix_expression unary_expression multiplicative_expression
%type <tipo> additive_expression relational_expression equality_expression
%type <tipo> logical_and_expression logical_or_expression conditional_expression
%type <tipo> type_spec

%type <ast> translation_unit external_declaration function_definition
%type <ast> compound_stmt stmt_list_opt
%type <ast> stmt declaration declaration_nosemi expr_stmt
%type <ast> initializer_value
%type <ast> selection_stmt iteration_stmt jump_stmt
%type <ast> init_declarator init_declarator_list
%type <ast> expr_ast assignment_expr_ast primary_expr_ast
%type <ast> additive_expr_ast multiplicative_expr_ast
%type <ast> relational_expr_ast equality_expr_ast
%type <ast> logical_and_expr_ast logical_or_expr_ast
%type <ast> unary_expr_ast postfix_expr_ast
%type <ast> argument_expr_list_opt argument_expr_list 
%type <ast> param_list_opt param_list param_decl

%start translation_unit
%%

translation_unit
  : external_declaration
    {
      $$ = criarPrograma($1, yylineno);
      ast_raiz = $$;
      printf("[AST] Programa criado\n");
    }
  | translation_unit external_declaration
    {
      if ($2 && $2->tipo != AST_VAZIO)
        $$ = adicionarDeclaracao($1, $2);
      else
        $$ = $1;
      ast_raiz = $$;
    }
  ;

external_declaration
  : declaration
  | function_definition
  | error SEMI { yyerrok; $$ = criarVazio(); }
  ;

function_definition
  : storage_class_opt type_spec IDENT LPAREN param_list_opt RPAREN compound_stmt
    {
      printf("[FUNC] Definição de função '%s'\n", $3);
      $$ = criarDeclaracaoFuncao(tipo_atual, $3, $5, $7, yylineno);
      free($3);
    }
  ;

declaration
  : storage_class_opt type_spec declarator ASSIGN initializer_value SEMI
    {
        $$ = criarDeclaracaoVar(tipo_atual, $3, $5, yylineno);
        printf("[INIT] Variável '%s' inicializada com valor\n", $3);
    }
  | storage_class_opt type_spec declarator SEMI
    {
        $$ = criarDeclaracaoVar(tipo_atual, $3, criarVazio(), yylineno);
    }
  ;
declaration_nosemi
  : type_spec init_declarator_list
    { $$ = $2; }
  ;

storage_class_opt
  : /* vazio */        { /* sem modificador */ }
  | T_STATIC           
    { 
      fprintf(stderr, "[YACC] Modificador 'static' detectado (será ignorado na geração de código)\n"); 
    }
  ;

type_spec
  : T_INT
      { $$ = TIPO_INT; tipo_atual = TIPO_INT; }
  | T_FLOAT
      { $$ = TIPO_FLOAT; tipo_atual = TIPO_FLOAT; }
  | T_CHAR
      { $$ = TIPO_CHAR; tipo_atual = TIPO_CHAR; }
  | T_VOID
      { $$ = TIPO_VOID; tipo_atual = TIPO_VOID; }
  ;


init_declarator_list
  : init_declarator
    { $$ = $1 ? $1 : criarVazio(); }
  | init_declarator_list COMMA init_declarator
    { $$ = criarLista($1, $3 ? $3 : criarVazio()); }
  ;

init_declarator
  : declarator
    {
      printf("[DECL] Variável '%s' declarada\n", $1);
      $$ = criarDeclaracaoVar(tipo_atual, $1, NULL, yylineno);
      free($1);
    }
  | declarator ASSIGN initializer_value
    {
      printf("[INIT] Variável '%s' inicializada com valor\n", $1);
      marcarInicializada($1);
      $$ = criarDeclaracaoVar(tipo_atual, $1, $3, yylineno);
      free($1);
    }
  ;

initializer_value
  : expr_ast
    { $$ = $1; }
  ;

declarator
  : pointer_opt IDENT
    {
        $$ = $2;
        ptr_level_atual = $1;
        printf("[DECL] %s (ptr_level=%d)\n", $2, ptr_level_atual);
    }
  ;

pointer_opt
  : /* vazio */
      { $$ = 0; }
  | STAR pointer_opt
      { $$ = $2 + 1; }
  ;

param_list_opt
  : /* vazio */     { $$ = criarVazio(); }
  | T_VOID          { $$ = criarVazio(); }  
  | param_list      { $$ = $1; }
  ;

param_list
  : param_decl
  | param_list COMMA param_decl
  ;

param_decl
  : type_spec pointer_opt IDENT              
    { show_decl(tipoParaString($1), $3, $2); free($3); }
  ;

compound_stmt
  : LBRACE stmt_list_opt RBRACE
    { $$ = criarBloco($2, yylineno); }
  ;

stmt_list_opt
  : /* vazio */
    { $$ = criarVazio(); }
  | stmt_list_opt stmt
    {
        if ($1->tipo == AST_VAZIO) {
            $$ = $2;
        } else {
            $$ = criarLista($1, $2);
        }
    }
  ;

stmt
  : declaration    
      { $$ = $1; }
  | expr_stmt     
      { $$ = $1; }
  | selection_stmt      
      { $$ = $1; }
  | iteration_stmt      
      { $$ = $1; }
  | jump_stmt           
      { $$ = $1; }
  | compound_stmt       
      { $$ = $1; }
  | SEMI                
      { $$ = criarVazio(); }
  ;


expr_stmt
  : expr_ast SEMI
    { $$ = criarExprStmt($1, yylineno); }
  ;

selection_stmt
  : IF LPAREN expr_ast RPAREN stmt
    { $$ = criarIf($3, $5, NULL, yylineno); }
  | IF LPAREN expr_ast RPAREN stmt ELSE stmt
    { $$ = criarIf($3, $5, $7, yylineno); }
  ;

iteration_stmt
  : WHILE LPAREN expr_ast RPAREN stmt
    { $$ = criarWhile($3, $5, yylineno); }
  | FOR LPAREN for_init_opt SEMI for_condition_opt SEMI for_increment_opt RPAREN stmt
    {
        $$ = criarFor(criarVazio(), criarVazio(), criarVazio(), $9, yylineno);
    }
  ;

for_init_opt
  : /* vazio */
  | expression
  | declaration_nosemi
  ;

for_condition_opt
  : /* vazio */
  | expression
  ;

for_increment_opt
  : /* vazio */
  | expression
  ;

jump_stmt
  : RETURN expr_ast SEMI
    { $$ = criarReturn($2, yylineno); }
  | RETURN SEMI
    { $$ = criarReturn(NULL, yylineno); }
  ;

/* Análise semântica (tipos) */
expression
  : assignment_expression                              
    { $$ = $1; }
  | expression COMMA assignment_expression             
    { $$ = $3; }
  ;

assignment_expression
  : conditional_expression                                      
    { $$ = $1; }
  | unary_expression ASSIGN assignment_expression               
    { 
        printf("[ASSIGN] =\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Atribuição incompatível.\n", yylineno);
        }
        $$ = $1;
    }
  | unary_expression PLUSEQ assignment_expression               
    { 
        printf("[ASSIGN] +=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação += incompatível.\n", yylineno);
        }
        $$ = $1;
    }
  | unary_expression MINUSEQ assignment_expression              
    { 
        printf("[ASSIGN] -=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação -= incompatível.\n", yylineno);
        }
        $$ = $1;
    }
  | unary_expression STAREQ assignment_expression               
    { 
        printf("[ASSIGN] *=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação *= incompatível.\n", yylineno);
        }
        $$ = $1;
    }
  | unary_expression SLASHEQ assignment_expression              
    { 
        printf("[ASSIGN] /=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação /= incompatível.\n", yylineno);
        }
        $$ = $1;
    }
  | unary_expression PERCENTEQ assignment_expression            
    { 
        printf("[ASSIGN] %%=\n");
        if ($1 != TIPO_INT || $3 != TIPO_INT) {
            fprintf(stderr, "Erro semântico (linha %d): Operação %%= requer int.\n", yylineno);
        }
        $$ = TIPO_INT;
    }
  ;

conditional_expression
  : logical_or_expression
    { $$ = $1; }
  ;

logical_or_expression
  : logical_and_expression
    { $$ = $1; }
  | logical_or_expression OROR logical_and_expression
    { $$ = TIPO_INT; }
  ;

logical_and_expression
  : equality_expression
    { $$ = $1; }
  | logical_and_expression ANDAND equality_expression
    { $$ = TIPO_INT; }
  ;

equality_expression
  : relational_expression
    { $$ = $1; }
  | equality_expression EQ relational_expression
    { $$ = TIPO_INT; }
  | equality_expression NE relational_expression
    { $$ = TIPO_INT; }
  ;

relational_expression
  : additive_expression
    { $$ = $1; }
  | relational_expression LT additive_expression
    { $$ = TIPO_INT; }
  | relational_expression LE additive_expression
    { $$ = TIPO_INT; }
  | relational_expression GT additive_expression
    { $$ = TIPO_INT; }
  | relational_expression GE additive_expression
    { $$ = TIPO_INT; }
  ;

additive_expression
  : multiplicative_expression
    { $$ = $1; }
  | additive_expression PLUS multiplicative_expression
    { $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1; }
  | additive_expression MINUS multiplicative_expression
    { $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1; }
  ;

multiplicative_expression
  : unary_expression
    { $$ = $1; }
  | multiplicative_expression STAR unary_expression
    { $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1; }
  | multiplicative_expression SLASH unary_expression
    { $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1; }
  | multiplicative_expression PERCENT unary_expression
    { 
        if ($1 != TIPO_INT || $3 != TIPO_INT) {
            fprintf(stderr, "Erro semântico (linha %d): Operador %% requer int.\n", yylineno);
        }
        $$ = TIPO_INT;
    }
  ;

unary_expression
  : postfix_expression
    { $$ = $1; }
  | AMP unary_expression %prec UAMP
    { printf("[PTR] addr-of\n"); $$ = $2; }
  | STAR unary_expression %prec USTAR
    { printf("[PTR] deref\n"); $$ = $2; }
  | MINUS unary_expression %prec UMINUS
    { $$ = $2; }
  | NOT unary_expression
    { $$ = TIPO_INT; }
  ;

postfix_expression
  : primary_expression
    { $$ = $1; }
  | postfix_expression LBRACK expression RBRACK
    { $$ = $1; }
  | postfix_expression LPAREN argument_expr_list_opt RPAREN
    { $$ = TIPO_DESCONHECIDO; }
  | postfix_expression DOT IDENT
    { $$ = TIPO_DESCONHECIDO; }
  | postfix_expression ARROW IDENT
    { $$ = TIPO_DESCONHECIDO; }
  ;

argument_expr_list_opt
  : /* vazio */             
      { $$ = NULL; }
  | argument_expr_list       
      { $$ = $1; }
  ;

argument_expr_list
  : assignment_expr_ast
      { 
          $$ = criarLista($1, NULL);
          fprintf(stderr, "✅ [YACC] argumento único criado\n");
      }
  | argument_expr_list COMMA assignment_expr_ast
      { 
          // Encontrar o último nó da lista
          Ast *ultimo = $1;
          while (ultimo->tipo == AST_LISTA && ultimo->dados.lista.proximo != NULL) {
              ultimo = ultimo->dados.lista.proximo;
          }
          
          // Adicionar novo argumento no final
          if (ultimo->tipo == AST_LISTA) {
              ultimo->dados.lista.proximo = criarLista($3, NULL);
          } else {
              // Primeiro elemento não era lista, criar lista
              $$ = criarLista($1, criarLista($3, NULL));
          }
          
          $$ = $1;  // Retornar a lista completa
          fprintf(stderr, "✅ [YACC] argumento adicionado à lista\n");
      }
  ;

primary_expression
  : IDENT
    {
        /* Checagem semântica movida para fase posterior
        Simbolo *s = buscarSimbolo($1);
        if (s == NULL) {
            fprintf(stderr, "Erro semântico (linha %d): Variável '%s' não declarada.\n", yylineno, $1);
            $$ = TIPO_DESCONHECIDO;
        } else {
            if (!s->inicializada) {
                fprintf(stderr, "Aviso (linha %d): Variável '%s' pode não ter sido inicializada.\n", yylineno, $1);
            }
            $$ = s->tipo;
        }
        */
        $$ = TIPO_INT; /* Tipo padrão por enquanto */
        free($1);
    }
  | ICONST
    { $$ = TIPO_INT; }
  | FCONST
    { $$ = TIPO_FLOAT; free($1); }
  | SCONST
    { $$ = TIPO_CHAR; free($1); }
  | T_NULL
    { $$ = TIPO_VOID; }
  | LPAREN expression RPAREN
    { $$ = $2; }
  ;

/* Construção da AST */
expr_ast
  : assignment_expr_ast
      { $$ = $1; }
  ;

assignment_expr_ast
  : unary_expr_ast ASSIGN expr_ast
      { 
          printf("[AST] Atribuição detectada: linha %d\n", yylineno);
          $$ = criarAtribuicao($1, $3, yylineno); 
      }
  | logical_or_expr_ast
      { $$ = $1; }
  ;


logical_or_expr_ast
  : logical_and_expr_ast
    { $$ = $1; }
  | logical_or_expr_ast OROR logical_and_expr_ast
    { $$ = criarOpBinario(OP_OR, $1, $3, yylineno); }
  ;

logical_and_expr_ast
  : equality_expr_ast
    { $$ = $1; }
  | logical_and_expr_ast ANDAND equality_expr_ast
    { $$ = criarOpBinario(OP_AND, $1, $3, yylineno); }
  ;

equality_expr_ast
  : relational_expr_ast
    { $$ = $1; }
  | equality_expr_ast EQ relational_expr_ast
    { $$ = criarOpBinario(OP_EQ, $1, $3, yylineno); }
  | equality_expr_ast NE relational_expr_ast
    { $$ = criarOpBinario(OP_NE, $1, $3, yylineno); }
  ;

relational_expr_ast
  : additive_expr_ast
    { $$ = $1; }
  | relational_expr_ast LT additive_expr_ast
    { $$ = criarOpBinario(OP_LT, $1, $3, yylineno); }
  | relational_expr_ast LE additive_expr_ast
    { $$ = criarOpBinario(OP_LE, $1, $3, yylineno); }
  | relational_expr_ast GT additive_expr_ast
    { $$ = criarOpBinario(OP_GT, $1, $3, yylineno); }
  | relational_expr_ast GE additive_expr_ast
    { $$ = criarOpBinario(OP_GE, $1, $3, yylineno); }
  ;

additive_expr_ast
  : multiplicative_expr_ast
    { $$ = $1; }
  | additive_expr_ast PLUS multiplicative_expr_ast
    { $$ = criarOpBinario(OP_MAIS, $1, $3, yylineno); }
  | additive_expr_ast MINUS multiplicative_expr_ast
    { $$ = criarOpBinario(OP_MENOS, $1, $3, yylineno); }
  ;

multiplicative_expr_ast
  : unary_expr_ast
    { $$ = $1; }
  | multiplicative_expr_ast STAR unary_expr_ast
    { $$ = criarOpBinario(OP_MULT, $1, $3, yylineno); }
  | multiplicative_expr_ast SLASH unary_expr_ast
    { $$ = criarOpBinario(OP_DIV, $1, $3, yylineno); }
  | multiplicative_expr_ast PERCENT unary_expr_ast
    { $$ = criarOpBinario(OP_MOD, $1, $3, yylineno); }
  ;

unary_expr_ast
  : postfix_expr_ast
    { 
        $$ = $1;
    }
  | LPAREN type_spec pointer_opt RPAREN unary_expr_ast
    { 
        printf("[AST] (CAST) (%s", tipoParaString($2));
        if ($3 > 0) printf(" %*s", $3, "*");
        printf(") ignorado por enquanto\n");
        $$ = $5;  /* apenas propaga a expressão */
    }
  | AMP unary_expr_ast %prec UAMP
    { 
        printf("[AST] Operador & sobre expr tipo %d\n", $2 ? $2->tipo : (TipoNoAST)-1);
        $$ = criarOpUnario(OP_UN_ADDR, $2, yylineno); 
    }
  | STAR unary_expr_ast %prec USTAR
    { 
        printf("[AST] Operador * sobre expr tipo %d\n", $2 ? $2->tipo : (TipoNoAST)-1);
        $$ = criarOpUnario(OP_UN_DEREF, $2, yylineno); 
    }
  | MINUS unary_expr_ast %prec UMINUS
    { 
        printf("[AST] Operador unário - sobre expr tipo %d\n", $2 ? $2->tipo : (TipoNoAST)-1);
        $$ = criarOpUnario(OP_UN_MENOS, $2, yylineno); 
    }
  | NOT unary_expr_ast
    { 
        printf("[AST] Operador ! sobre expr tipo %d\n", $2 ? $2->tipo : (TipoNoAST)-1);
        $$ = criarOpUnario(OP_UN_NOT, $2, yylineno); 
    }
  ;

postfix_expr_ast
  : primary_expr_ast
    { $$ = $1; }
  | postfix_expr_ast LPAREN argument_expr_list_opt RPAREN
    { 
        // Extrair nome se for um identificador
        const char *nome = NULL;
        if ($1->tipo == AST_IDENTIFICADOR && $1->dados.identificador.nome) {
            nome = $1->dados.identificador.nome;
        }
        $$ = criarChamadaFuncao(nome, $3, yylineno); 
    }
  | postfix_expr_ast LBRACK expr_ast RBRACK
    { $$ = criarIndexacao($1, $3, yylineno); }
  ;

primary_expr_ast
  : IDENT
    {
        /* Checagem semântica movida para fase posterior
        Simbolo *s = buscarSimbolo($1);
        if (s == NULL) {
            fprintf(stderr, "Erro semântico (linha %d): Variável '%s' não declarada.\n", yylineno, $1);
        } else if (!s->inicializada) {
            fprintf(stderr, "Aviso (linha %d): Variável '%s' pode não ter sido inicializada.\n", yylineno, $1);
        }
        */
        $$ = criarIdentificador($1, yylineno);
        free($1);
    }
  | ICONST
    { $$ = criarLiteralInt($1, yylineno); }
  | FCONST
    { 
        float val = atof($1);
        $$ = criarLiteralFloat(val, yylineno);
        free($1);
    }
  | SCONST
    { 
        $$ = criarLiteralString($1, yylineno);
        free($1);
    }
  | T_NULL
    { $$ = criarLiteralInt(0, yylineno); }
  | LPAREN expr_ast RPAREN
    { $$ = $2; }
  ;
  
%%

void yyerror(const char* s) {
    fprintf(stderr, "\n=== ERRO SINTÁTICO ===\n");
    fprintf(stderr, "Linha %d: %s\n", yylineno, s);
    if (ultimo_token && ultimo_lexema) {
        fprintf(stderr, "Último token lido: %s ('%s')\n", ultimo_token, ultimo_lexema);
    } else {
        fprintf(stderr, "Último token/lexema indisponível.\n");
    }
    fprintf(stderr, "======================\n\n");
}