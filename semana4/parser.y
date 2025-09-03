%{
/*
 * parser.y — Parser (Bison) para linguagem Python-like com blocos por indentação.
 *
 * IDEA-CHAVE:
 *  - Após tokens ':' vem um "suite", que pode ser:
 *      a) uma única simple_stmt + NEWLINE, ou
 *      b) um bloco: NEWLINE INDENT stmts DEDENT
 *  - O lexer já entrega NEWLINE/INDENT/DEDENT prontos, então a gramática fica simples.
 *
 * ESQUELETO:
 *  - Por enquanto, o valor semântico é char* (strings). Em produção, troque por ponteiros de AST.
 *  - As ações só imprimem rastros (printf) para demonstrar reconhecimento.
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>

int yylex(void);
void yyerror(const char* s);
%}

/* tipo semântico inicial simples; depois substitua por AST* */
%define api.value.type {char*}

/* tokens vindos do scanner.l */
%token NEWLINE INDENT DEDENT
%token DEF IF ELIF ELSE WHILE RETURN PRINT
%token AND OR NOT TRUE FALSE NONE
%token ID INT_LIT STRING_LIT
%token PLUS MINUS STAR SLASHSLASH PERCENT
%token EQEQ NE LT LE GT GE ASSIGN
%token COLON COMMA LPAREN RPAREN
%token ERROR

/* precedência/associatividade para evitar conflitos de shift/reduce */
%left OR
%left AND
%right NOT
%left EQEQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR SLASHSLASH PERCENT
%right UMINUS

%%
/* Um programa é uma lista (possivelmente vazia) de statements */
program
  : stmts_opt                          { printf("[OK] programa reconhecido\n"); }
  ;

/* zero ou mais statements */
stmts_opt
  : /* vazio */
  | stmts_opt stmt
  ;

/* Um statement pode ser simples (termina com NEWLINE) ou composto (consome seu próprio bloco) */
stmt
  : simple_stmt NEWLINE
  | compound_stmt
  ;

/* Em Python, pode haver múltiplos small_stmt na mesma linha separados por vírgula (opcional aqui) */
simple_stmt
  : small_stmt
  | small_stmt COMMA small_stmt
  ;

/* small_stmt concretos */
small_stmt
  : expr                               { /* expressão solta (ex.: chamada) */ }
  | ID ASSIGN expr                     { printf("assign %s := expr\n", $1); }
  | PRINT LPAREN arglist_opt RPAREN    { printf("print(...)\n"); }
  | RETURN expr                        { printf("return expr\n"); }
  ;

/* compostos: if/while/def */
compound_stmt
  : if_stmt
  | while_stmt
  | funcdef
  ;

/* if/elif/else com suites indentadas */
if_stmt
  : IF expr COLON suite elif_list_opt else_opt   { printf("if/elif/else\n"); }
  ;

elif_list_opt
  : /* vazio */
  | elif_list_opt ELIF expr COLON suite
  ;

else_opt
  : /* vazio */
  | ELSE COLON suite
  ;

/* while expr: suite */
while_stmt
  : WHILE expr COLON suite                      { printf("while\n"); }
  ;

/* def nome(parâmetros): suite */
funcdef
  : DEF ID LPAREN params_opt RPAREN COLON suite { printf("def %s(...)\n", $2); }
  ;

/* parâmetros de função (opcionais) */
params_opt
  : /* vazio */
  | paramlist
  ;

paramlist
  : ID
  | paramlist COMMA ID
  ;

/* argumentos de chamada (opcionais) */
arglist_opt
  : /* vazio */
  | arglist
  ;

arglist
  : expr
  | arglist COMMA expr
  ;

/* suite: ou uma linha simples OU um bloco indentado */
suite
  : simple_stmt NEWLINE                   /* suite de 1 linha */
  | NEWLINE INDENT stmts DEDENT           /* bloco indentado */
  ;

/* múltiplos statements dentro do bloco */
stmts
  : stmt
  | stmts stmt
  ;

/* Expressões lógicas/relacionais/aritméticas básicas */
expr
  : or_test
  ;

or_test
  : and_test
  | or_test OR and_test
  ;

and_test
  : not_test
  | and_test AND not_test
  ;

not_test
  : NOT not_test
  | comparison
  ;

comparison
  : arith_expr
  | comparison EQEQ arith_expr
  | comparison NE   arith_expr
  | comparison LT   arith_expr
  | comparison LE   arith_expr
  | comparison GT   arith_expr
  | comparison GE   arith_expr
  ;

arith_expr
  : term
  | arith_expr PLUS  term
  | arith_expr MINUS term
  ;

term
  : factor
  | term STAR       factor
  | term SLASHSLASH factor
  | term PERCENT    factor
  ;

factor
  : atom
  | MINUS factor %prec UMINUS
  ;

atom
  : INT_LIT
  | STRING_LIT
  | TRUE
  | FALSE
  | NONE
  | ID
  | ID LPAREN arglist_opt RPAREN       /* chamada de função */
  | LPAREN expr RPAREN
  ;
%%

void yyerror(const char* s) {
  fprintf(stderr, "[SINTAXE] erro: %s\n", s);
}

int main() {
  return yyparse();
}
