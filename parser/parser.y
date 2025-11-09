/* parser.y – Bison
 * Subconjunto de C com ponteiros, blocos, if/else, while, retorno e expressões.
 * Compatível com lexer C-like (chaves) ou com Python-like se você mapear blocos depois.
 * Mantém gramática da branch feat (C + ponteiros) e yyerror detalhado da main.
 */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "../src/tabela_simbolos/tabela.h"

  int yylex(void);
  void yyerror(const char* s);

  /* Expostos pelo lexer (se implementar): */
  extern int yylineno;
  extern char *ultimo_token;
  extern char *ultimo_lexema;

  /* helper para logar declarações de ponteiro (debug) */
  static void show_decl(const char* type, const char* name, int ptr_level) {
    printf("[DECL] %s %s (ptr_level=%d)\n", type, name, ptr_level);
  }

  /* Variável global para rastrear o tipo atual da declaração */
  static Tipo tipo_atual = TIPO_DESCONHECIDO;

  /* Função auxiliar para converter string de tipo para enum Tipo */
  static Tipo stringParaTipo(const char* tipo_str) {
    if (strcmp(tipo_str, "int") == 0) return TIPO_INT;
    if (strcmp(tipo_str, "float") == 0) return TIPO_FLOAT;
    if (strcmp(tipo_str, "char") == 0) return TIPO_CHAR;
    if (strcmp(tipo_str, "void") == 0) return TIPO_VOID;
    return TIPO_DESCONHECIDO;
  }

  /* Função para verificar compatibilidade de tipos */
  static int tiposCompativeis(Tipo tipo1, Tipo tipo2) {
    if (tipo1 == tipo2) return 1;
    /* int e float são parcialmente compatíveis (com warning) */
    if ((tipo1 == TIPO_INT && tipo2 == TIPO_FLOAT) ||
        (tipo1 == TIPO_FLOAT && tipo2 == TIPO_INT)) {
        printf("Aviso: Conversão implícita entre int e float.\n");
        return 1;
    }
    return 0;
  }

  /* Pilha de escopos só para detectar redeclaração no MESMO escopo.
     Não substitui a tabela global (buscarSimbolo/inserirSimboloTipado). */
  typedef struct DeclNode {
    char *nome;
    int   is_array;
    struct DeclNode *next;
  } DeclNode;

  typedef struct Scope {
    DeclNode *head;
    struct Scope *prev;
  } Scope;

  static Scope *escopo_atual = NULL;

  static char* sdup(const char* s){
    size_t n = strlen(s);
    char* p = (char*)malloc(n+1);
    if(!p){ perror("malloc"); exit(1); }
    memcpy(p, s, n+1);
    return p;
  }

  static void ensure_global_scope(void){
    if(!escopo_atual){
      escopo_atual = (Scope*)calloc(1, sizeof(Scope));
      if(!escopo_atual){ perror("calloc"); exit(1); }
    }
  }

  static void enter_scope(void){
    Scope* s = (Scope*)calloc(1, sizeof(Scope));
    if(!s){ perror("calloc"); exit(1); }
    s->prev = escopo_atual;
    escopo_atual = s;
  }

  static void leave_scope(void){
    if(!escopo_atual) return;
    DeclNode* it = escopo_atual->head;
    while(it){
      DeclNode* nx = it->next;
      free(it->nome);
      free(it);
      it = nx;
    }
    Scope* prev = escopo_atual->prev;
    free(escopo_atual);
    escopo_atual = prev;
  }

  static int scope_has(const char* nome){
    if(!escopo_atual) return 0;
    for(DeclNode* it = escopo_atual->head; it; it = it->next){
      if(strcmp(it->nome, nome)==0) return 1;
    }
    return 0;
  }

  // registra no escopo atual para evitar redeclaração no mesmo escopo 
  static int scope_add(const char* nome, int is_array){
    ensure_global_scope();
    if(scope_has(nome)) return 0;
    DeclNode* n = (DeclNode*)calloc(1, sizeof(DeclNode));
    if(!n){ perror("calloc"); exit(1); }
    n->nome = sdup(nome);
    n->is_array = is_array;
    n->next = escopo_atual->head;
    escopo_atual->head = n;
    return 1;
  }

  /* Marca último IDENT e se é array para validar base[index] */
  static char* ultimo_ident = NULL;
  static int   ultimo_ident_is_array = 0;

  static void marcar_ident(const char* nome, int is_array){
    if(ultimo_ident){ free(ultimo_ident); ultimo_ident=NULL; }
    ultimo_ident = sdup(nome);
    ultimo_ident_is_array = is_array;
  }
  static void limpar_ident(void){
    if(ultimo_ident){ free(ultimo_ident); ultimo_ident=NULL; }
    ultimo_ident_is_array = 0;
  }

  extern const char* tipoParaString(Tipo); /* da tabela */

  static void verifica_indexacao(Tipo idx_tipo, int linha){
    if(idx_tipo != TIPO_INT){
      fprintf(stderr,
        "Erro semântico (linha %d): índice de array deve ser 'int' (recebido '%s').\n",
        linha, tipoParaString(idx_tipo));
    }
    if(!ultimo_ident || !ultimo_ident_is_array){
      const char* base = ultimo_ident ? ultimo_ident : "<expressão>";
      fprintf(stderr,
        "Erro semântico (linha %d): '%s' não é um array; uso de indexação inválido.\n",
        linha, base);
    }
    limpar_ident(); /* consome o contexto após base[index] */
  }
%}

/* Tipos do yylval */
%union {
  int    ival;
  char*  sval;
  int    n;         /* níveis de ponteiro, etc. */
  Tipo   tipo;      /* tipo da expressão */
}

/* Tokens do lexer */
%token T_INT T_CHAR T_VOID T_NULL T_FLOAT
%token IF ELSE WHILE RETURN
%token ANDAND OROR NOT
%token EQ NE LT LE GT GE
%token AMP STAR PLUS MINUS SLASH PERCENT
%token ASSIGN
%token PLUSEQ MINUSEQ STAREQ SLASHEQ PERCENTEQ
%token DOT ARROW
%token COMMA SEMI COLON
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token ICONST FCONST SCONST IDENT
%token BADCHAR

/* Precedência (da menor para a maior) */
%left OROR
%left ANDAND
%left EQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR SLASH PERCENT
%right NOT
%right UAMP USTAR UMINUS        /* unários: &  *  - */
%right ASSIGN PLUSEQ MINUSEQ STAREQ SLASHEQ PERCENTEQ

%type <n>    pointer_opt
%type <sval> type_spec
%type <sval> IDENT
%type <ival> ICONST
%type <sval> SCONST FCONST
%type <tipo> expression assignment_expression primary_expression
%type <tipo> postfix_expression unary_expression multiplicative_expression
%type <tipo> additive_expression relational_expression equality_expression
%type <tipo> logical_and_expression logical_or_expression conditional_expression

%%

/* ---------- Unidade de tradução (mantemos C, descartamos a "calculadora") ---------- */
translation_unit
  : external_declaration
  | translation_unit external_declaration
  ;

/* Adiciona uma regra especial para imprimir a tabela ao final */
programa
  : translation_unit
    {
        printf("\n=== ANÁLISE CONCLUÍDA ===\n");
        imprimirTabela();
    }
  ;

external_declaration
  : function_def
  | declaration SEMI
  | SEMI
  ;

/* ---------- Declarações ---------- */

declaration
  : type_spec init_declarator_list
  ;

type_spec
  : T_INT     { $$ = "int"; tipo_atual = TIPO_INT; }
  | T_FLOAT   { $$ = "float"; tipo_atual = TIPO_FLOAT; }
  | T_CHAR    { $$ = "char"; tipo_atual = TIPO_CHAR; }
  | T_VOID    { $$ = "void"; tipo_atual = TIPO_VOID; }
  ;

init_declarator_list
  : init_declarator
  | init_declarator_list COMMA init_declarator
  ;

init_declarator
  : declarator                               
    { /* declaração sem inicialização - não marca como inicializada */ }
  | declarator ASSIGN initializer            
    { /* declaração com inicialização - será marcada no declarator */ }
  ;

declarator
  : pointer_opt IDENT
    {
        /* [SEM] redeclaração no MESMO escopo */
        ensure_global_scope();
        if(!scope_add($2, 0)){
          fprintf(stderr,
            "Erro semântico (linha %d): redeclaração de '%s' no mesmo escopo.\n",
            yylineno, $2);
        } else {
          inserirSimboloTipado($2, CATEGORIA_VARIAVEL, tipo_atual, $1);
          show_decl(tipoParaString(tipo_atual), $2, $1);
        }
        free($2);
    }
  | pointer_opt IDENT LBRACK ICONST RBRACK
    {
        /* [SEM] redeclaração no MESMO escopo (array) */
        ensure_global_scope();
        if(!scope_add($2, 1)){
          fprintf(stderr,
            "Erro semântico (linha %d): redeclaração de '%s' no mesmo escopo.\n",
            yylineno, $2);
        } else {
          inserirSimboloTipado($2, CATEGORIA_ARRAY, tipo_atual, $1);
          show_decl("/* array */", $2, $1);
        }
        free($2);
    }
  ;

/* ponteiro: zero ou mais '*' antes do identificador */
pointer_opt
  : /* vazio */      { $$ = 0; }
  | pointer_opt STAR { $$ = $1 + 1; }
  ;

initializer
  : assignment_expression
  ;

/* ---------- Função ---------- */

function_def
  : type_spec declarator_func compound_stmt
  ;

declarator_func
  : IDENT LPAREN param_list_opt RPAREN       { /* nome da função em $1 */ free($1); }
  | STAR declarator_func                     { /* ponteiro para função - aceita sintaticamente */ }
  ;

param_list_opt
  : /* vazio */
  | param_list
  ;

param_list
  : param_decl
  | param_list COMMA param_decl
  ;

param_decl
  : type_spec pointer_opt IDENT              { show_decl($1, $3, $2); free($3); }
  ;

/* ---------- Blocos e statements (C com chaves) ---------- */

compound_stmt
  : LBRACE   { enter_scope(); }   /* [SEM] entra escopo */
    stmt_list_opt
    RBRACE   { leave_scope(); }   /* [SEM] sai escopo   */
  ;

stmt_list_opt
  : /* vazio */
  | stmt_list_opt stmt
  ;

stmt
  : declaration SEMI
  | expr_stmt
  | selection_stmt
  | iteration_stmt
  | jump_stmt
  | SEMI
  ;

expr_stmt
  : expression SEMI
  ;

selection_stmt
  : IF LPAREN expression RPAREN stmt
  | IF LPAREN expression RPAREN stmt ELSE stmt
  ;

iteration_stmt
  : WHILE LPAREN expression RPAREN stmt
  ;

jump_stmt
  : RETURN expression SEMI
  | RETURN SEMI
  ;

/* ---------- Expressões ---------- */

expression
  : assignment_expression                              { $$ = $1; }
  | expression COMMA assignment_expression             { $$ = $3; /* resultado da vírgula é o último */ }
  ;

assignment_expression
  : conditional_expression                                      
    { $$ = $1; }
  | unary_expression ASSIGN assignment_expression               
    { 
        printf("[ASSIGN] =\n");
        // Verifica compatibilidade de tipos
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Atribuição incompatível entre tipos '%s' e '%s'.\n",
                    yylineno, tipoParaString($1), tipoParaString($3));
        }
        $$ = $1;  // tipo resultante é o tipo da variável à esquerda
    }
  | unary_expression PLUSEQ assignment_expression               
    { 
        printf("[ASSIGN] +=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação += incompatível entre tipos '%s' e '%s'.\n",
                    yylineno, tipoParaString($1), tipoParaString($3));
        }
        $$ = $1;
    }
  | unary_expression MINUSEQ assignment_expression              
    { 
        printf("[ASSIGN] -=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação -= incompatível entre tipos '%s' e '%s'.\n",
                    yylineno, tipoParaString($1), tipoParaString($3));
        }
        $$ = $1;
    }
  | unary_expression STAREQ assignment_expression               
    { 
        printf("[ASSIGN] *=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação *= incompatível entre tipos '%s' e '%s'.\n",
                    yylineno, tipoParaString($1), tipoParaString($3));
        }
        $$ = $1;
    }
  | unary_expression SLASHEQ assignment_expression              
    { 
        printf("[ASSIGN] /=\n");
        if (!tiposCompativeis($1, $3)) {
            fprintf(stderr, "Erro semântico (linha %d): Operação /= incompatível entre tipos '%s' e '%s'.\n",
                    yylineno, tipoParaString($1), tipoParaString($3));
        }
        $$ = $1;
    }
  | unary_expression PERCENTEQ assignment_expression            
    { 
        printf("[ASSIGN] %%=\n");
        // Módulo só funciona com int
        if ($1 != TIPO_INT || $3 != TIPO_INT) {
            fprintf(stderr, "Erro semântico (linha %d): Operação %%= requer operandos do tipo int.\n", yylineno);
        }
        $$ = TIPO_INT;
    }
  ;

conditional_expression
  : logical_or_expression                              { $$ = $1; }
  ;

logical_or_expression
  : logical_and_expression                             { $$ = $1; }
  | logical_or_expression OROR logical_and_expression  { $$ = TIPO_INT; /* resultado booleano */ }
  ;

logical_and_expression
  : equality_expression                                     { $$ = $1; }
  | logical_and_expression ANDAND equality_expression       { $$ = TIPO_INT; /* resultado booleano */ }
  ;

equality_expression
  : relational_expression                                   { $$ = $1; }
  | equality_expression EQ relational_expression            { $$ = TIPO_INT; /* resultado booleano */ }
  | equality_expression NE relational_expression            { $$ = TIPO_INT; /* resultado booleano */ }
  ;

relational_expression
  : additive_expression                                     { $$ = $1; }
  | relational_expression LT additive_expression            { $$ = TIPO_INT; /* resultado booleano */ }
  | relational_expression LE additive_expression            { $$ = TIPO_INT; /* resultado booleano */ }
  | relational_expression GT additive_expression            { $$ = TIPO_INT; /* resultado booleano */ }
  | relational_expression GE additive_expression            { $$ = TIPO_INT; /* resultado booleano */ }
  ;

additive_expression
  : multiplicative_expression                               { $$ = $1; }
  | additive_expression PLUS multiplicative_expression      
    { 
        // Promove para float se algum operando for float
        $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1;
    }
  | additive_expression MINUS multiplicative_expression     
    { 
        $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1;
    }
  ;

multiplicative_expression
  : unary_expression                                        { $$ = $1; }
  | multiplicative_expression STAR unary_expression         
    { 
        $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1;
    }
  | multiplicative_expression SLASH unary_expression        
    { 
        $$ = ($1 == TIPO_FLOAT || $3 == TIPO_FLOAT) ? TIPO_FLOAT : $1;
    }
  | multiplicative_expression PERCENT unary_expression      
    { 
        // Módulo só funciona com int
        if ($1 != TIPO_INT || $3 != TIPO_INT) {
            fprintf(stderr, "Erro semântico (linha %d): Operador %% requer operandos do tipo int.\n", yylineno);
        }
        $$ = TIPO_INT;
    }
  ;

/* --- PONTEIROS: & (address-of) e * (deref) no nível unário --- */
unary_expression
  : postfix_expression                                      { $$ = $1; }
  | AMP unary_expression        %prec UAMP                  
    { 
        printf("[PTR] addr-of\n"); 
        $$ = $2;  // tipo do ponteiro
    }
  | STAR unary_expression       %prec USTAR                 
    { 
        printf("[PTR] deref\n"); 
        $$ = $2;  // tipo desreferenciado
    }
  | MINUS unary_expression      %prec UMINUS                { $$ = $2; }
  | NOT unary_expression                                    { $$ = TIPO_INT; /* resultado booleano */ }
  ;

postfix_expression
  : primary_expression
    { $$ = $1; }
  | postfix_expression LBRACK expression RBRACK
    {
        /* [SEM] valida base[index] */
        verifica_indexacao($3, yylineno);
        $$ = $1; /* tipo do elemento, mantem comportamento atual */
    }
  | postfix_expression LPAREN argument_expr_list_opt RPAREN { $$ = TIPO_DESCONHECIDO; }
  | postfix_expression DOT IDENT                            { $$ = TIPO_DESCONHECIDO; }
  | postfix_expression ARROW IDENT                          { $$ = TIPO_DESCONHECIDO; }
  ;

argument_expr_list_opt
  : /* vazio */
  | argument_expr_list
  ;

argument_expr_list
  : assignment_expression
  | argument_expr_list COMMA assignment_expression
  ;

primary_expression
  : IDENT
    {
        /* Verifica se a variável foi declarada (na tabela global) */
        Simbolo *s = buscarSimbolo($1);
        if (s == NULL) {
            fprintf(stderr, "Erro semântico (linha %d): Variável '%s' não declarada.\n", yylineno, $1);
            $$ = TIPO_DESCONHECIDO;
            limpar_ident();
        } else {
            // Verifica se foi inicializada (apenas warning)
            if (!s->inicializada) {
                fprintf(stderr, "Aviso (linha %d): Variável '%s' pode não ter sido inicializada.\n", yylineno, $1);
            }
            $$ = s->tipo;
            /* [SEM] marca IDENT p/ validação de indexação */
            int is_array = (s->categoria == CATEGORIA_ARRAY);
            marcar_ident($1, is_array);
        }
        free($1);
    }
  | ICONST     { $$ = TIPO_INT;   limpar_ident(); }
  | FCONST     { $$ = TIPO_FLOAT; free($1); limpar_ident(); }
  | SCONST     { $$ = TIPO_CHAR;  free($1); limpar_ident(); } // strings e chars são tratados como char
  | T_NULL     { $$ = TIPO_VOID;  limpar_ident(); } // NULL tem tipo void*
  | LPAREN expression RPAREN
    { $$ = $2; limpar_ident(); }
  ;

%%

/* yyerror detalhado (trazido e adaptado da main) */
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
