%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char* s);
%}

%define api.value.type {char*}

%token NEWLINE INDENT DEDENT
%token DEF IF ELIF ELSE WHILE RETURN PRINT
%token AND OR NOT TRUE FALSE NONE
%token ID INT_LIT STRING_LIT
%token PLUS MINUS STAR SLASHSLASH PERCENT
%token EQEQ NE LT LE GT GE ASSIGN
%token COLON COMMA LPAREN RPAREN
%token ERROR

%left OR
%left AND
%right NOT
%left EQEQ NE
%left LT LE GT GE
%left PLUS MINUS
%left STAR SLASHSLASH PERCENT
%right UMINUS

%%

program
  : stmts_opt                          { printf("[OK] programa reconhecido\n"); }
  ;

stmts_opt
  : /* vazio */
  | stmts_opt stmt
  ;

stmt
  : simple_stmt NEWLINE
  | compound_stmt
  ;

simple_stmt
  : small_stmt
  ;

small_stmt
  : expr                               
  | ID ASSIGN expr                     { printf("assign %s := expr\n", $1); }
  | PRINT LPAREN arglist_opt RPAREN    { printf("print(...)\n"); }
  | RETURN expr                        { printf("return expr\n"); }
  ;

compound_stmt
  : if_stmt
  | while_stmt
  | funcdef
  ;

if_stmt
  : IF expr COLON suite                { printf("if\n"); }
  ;

while_stmt
  : WHILE expr COLON suite             { printf("while\n"); }
  ;

funcdef
  : DEF ID LPAREN params_opt RPAREN COLON suite { printf("def %s(...)\n", $2); }
  ;

params_opt
  : /* vazio */
  | paramlist
  ;

paramlist
  : ID
  | paramlist COMMA ID
  ;

arglist_opt
  : /* vazio */
  | arglist
  ;

arglist
  : expr
  | arglist COMMA expr
  ;

suite
  : simple_stmt NEWLINE                   
  | NEWLINE INDENT stmts
  ;

stmts
  : stmt
  | stmts stmt
  ;

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
  | ID LPAREN arglist_opt RPAREN       
  | LPAREN expr RPAREN
  ;

%%

void yyerror(const char* s) {
  fprintf(stderr, "[SINTAXE] erro: %s\n", s);
}

int main() {
  return yyparse();
}
