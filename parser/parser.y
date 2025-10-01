/* parser.y – Bison
 * Subconjunto de C com ponteiros, blocos, if/else, while, retorno e expressões.
 * Compatível com lexer C-like (chaves) ou com Python-like se você mapear blocos depois.
 * Mantém gramática da branch feat (C + ponteiros) e yyerror detalhado da main.
 */

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

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
%}

/* Tipos do yylval */
%union {
  int    ival;
  char*  sval;
  int    n;         /* níveis de ponteiro, etc. */
}

/* Tokens do lexer */
%token T_INT T_CHAR T_VOID T_NULL
%token IF ELSE WHILE RETURN
%token ANDAND OROR NOT
%token EQ NE LT LE GT GE
%token AMP STAR PLUS MINUS SLASH PERCENT
%token ASSIGN
%token PLUSEQ MINUSEQ STAREQ SLASHEQ PERCENTEQ
%token DOT ARROW
%token COMMA SEMI COLON
%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token ICONST SCONST IDENT
%token NEWLINE BADCHAR

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
%type <sval> SCONST

%%

/* ---------- Unidade de tradução (mantemos C, descartamos a "calculadora") ---------- */
translation_unit
  : external_declaration
  | translation_unit external_declaration
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
  : T_INT     { $$ = "int"; }
  | T_CHAR    { $$ = "char"; }
  | T_VOID    { $$ = "void"; }
  ;

init_declarator_list
  : init_declarator
  | init_declarator_list COMMA init_declarator
  ;

init_declarator
  : declarator                               { /* ex: int *p; */ }
  | declarator ASSIGN initializer            { /* ex: int *p = &x; */ }
  ;

declarator
  : pointer_opt IDENT                        { show_decl("/* type set later */", $2, $1); free($2); }
  | pointer_opt IDENT LBRACK ICONST RBRACK   { show_decl("/* array */", $2, $1); free($2); }
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
  : LBRACE stmt_list_opt RBRACE
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
  : assignment_expression
  | expression COMMA assignment_expression   /* vírgula associativa à esquerda */
  ;

assignment_expression
  : conditional_expression
  | unary_expression ASSIGN assignment_expression     { printf("[ASSIGN] =\n"); }
  | unary_expression PLUSEQ assignment_expression     { printf("[ASSIGN] +=\n"); }
  | unary_expression MINUSEQ assignment_expression    { printf("[ASSIGN] -=\n"); }
  | unary_expression STAREQ assignment_expression     { printf("[ASSIGN] *=\n"); }
  | unary_expression SLASHEQ assignment_expression    { printf("[ASSIGN] /=\n"); }
  | unary_expression PERCENTEQ assignment_expression  { printf("[ASSIGN] %%=\n"); }
  ;

conditional_expression
  : logical_or_expression
  ;

logical_or_expression
  : logical_and_expression
  | logical_or_expression OROR logical_and_expression
  ;

logical_and_expression
  : equality_expression
  | logical_and_expression ANDAND equality_expression
  ;

equality_expression
  : relational_expression
  | equality_expression EQ relational_expression
  | equality_expression NE relational_expression
  ;

relational_expression
  : additive_expression
  | relational_expression LT additive_expression
  | relational_expression LE additive_expression
  | relational_expression GT additive_expression
  | relational_expression GE additive_expression
  ;

additive_expression
  : multiplicative_expression
  | additive_expression PLUS multiplicative_expression
  | additive_expression MINUS multiplicative_expression
  ;

multiplicative_expression
  : unary_expression
  | multiplicative_expression STAR unary_expression
  | multiplicative_expression SLASH unary_expression
  | multiplicative_expression PERCENT unary_expression
  ;

/* --- PONTEIROS: & (address-of) e * (deref) no nível unário --- */
unary_expression
  : postfix_expression
  | AMP unary_expression        %prec UAMP   { printf("[PTR] addr-of\n"); }   /* &x  */
  | STAR unary_expression       %prec USTAR  { printf("[PTR] deref\n"); }     /* *p  */
  | MINUS unary_expression      %prec UMINUS
  | NOT unary_expression
  ;

postfix_expression
  : primary_expression
  | postfix_expression LBRACK expression RBRACK                 /* indexação */
  | postfix_expression LPAREN argument_expr_list_opt RPAREN     /* chamada */
  | postfix_expression DOT IDENT
  | postfix_expression ARROW IDENT
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
  | ICONST
  | SCONST
  | T_NULL
  | LPAREN expression RPAREN
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
