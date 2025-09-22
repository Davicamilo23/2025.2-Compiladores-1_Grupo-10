%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Declarações do lexer e função de erro */
int yylex(void);
void yyerror(const char *s);

/* Variáveis globais para controle de linha e último token */
extern int yylineno;
extern char *ultimo_token;
extern char *ultimo_lexema;

/* Contador de expressões válidas processadas */
int expressoes_validas = 0;
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
  | inicio expressao '\n' { 
        printf("Resultado: %d\n", $2); 
        expressoes_validas++;
    }
  | inicio error '\n' { 
        /* Recuperação de erro: ignora linha com erro e continua */
        yyerrok; 
    }
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

/* Função de erro melhorada */
void yyerror(const char *s) {
    fprintf(stderr, "\n=== ERRO SINTÁTICO ===\n");
    fprintf(stderr, "Linha %d: %s\n", yylineno, s);
    
    if (ultimo_token && ultimo_lexema) {
        fprintf(stderr, "Último token lido: %s ('%s')\n", ultimo_token, ultimo_lexema);
    } else {
        fprintf(stderr, "Nenhum token foi lido ainda.\n");
    }
    
    fprintf(stderr, "======================\n\n");
}

/* Função main melhorada */
int main(void) {
    printf("=== CALCULADORA COM TRATAMENTO DE ERROS ===\n");
    printf("Digite expressões aritméticas (uma por linha):\n");
    printf("Exemplo: 2 + 3 * 4\n");
    printf("Pressione Ctrl+D para sair.\n\n");
    
    int resultado = yyparse();
    
    printf("\n=== RESUMO DA EXECUÇÃO ===\n");
    printf("Expressões válidas processadas: %d\n", expressoes_validas);
    
    if (resultado == 0) {
        printf("Análise concluída com sucesso.\n");
    } else {
        printf("Análise concluída com erros.\n");
    }
    
    /* Liberar memória */
    if (ultimo_token) free(ultimo_token);
    if (ultimo_lexema) free(ultimo_lexema);
    
    return resultado;
}
