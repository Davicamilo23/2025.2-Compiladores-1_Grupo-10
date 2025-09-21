%{
#include <stdio.h>
#include <stdlib.h>

/* Declarações do lexer e função de erro */
int yylex(void);
void yyerror(const char *s);
%}

/* Tokens definidos no lexer */
%token NUM PLUS MINUS TIMES DIVIDE LPAREN RPAREN

/* Precedência e associatividade dos operadores */
%left PLUS MINUS
%left TIMES DIVIDE

%%

/* Regra inicial: aceita múltiplas expressões separadas por \n */
inicio:
    /* vazio */
  | inicio expressao '\n' { printf("Resultado: %d\n", $2); }
  ;

/* Regras de expressão com precedência */
expressao:
    expressao PLUS termo  { $$ = $1 + $3; }
  | expressao MINUS termo { $$ = $1 - $3; }
  | termo                 { $$ = $1; }
  ;

termo:
    termo TIMES fator  { $$ = $1 * $3; }
  | termo DIVIDE fator { $$ = $1 / $3; }
  | fator              { $$ = $1; }
  ;

fator:
    NUM                  { $$ = $1; }
  | LPAREN expressao RPAREN { $$ = $2; }
  ;

%%

/* Função de erro */
void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático: %s\n", s);
}

/* Função main */
int main(void) {
    printf("Digite expressões (Ctrl+D para sair):\n");
    yyparse();
    return 0;
}
