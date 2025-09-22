%{
#include "parser.tab.h"
#include <string.h>

/* Variáveis globais para controle de erro */
extern int yylineno;
extern char *ultimo_token;
extern char *ultimo_lexema;

char *ultimo_token = NULL;
char *ultimo_lexema = NULL;

/* Função para atualizar último token/lexema */
void atualizar_ultimo_token(const char *token, const char *lexema) {
    if (ultimo_token) free(ultimo_token);
    if (ultimo_lexema) free(ultimo_lexema);
    ultimo_token = strdup(token);
    ultimo_lexema = strdup(lexema);
}
%}

%option yylineno

%%

[0-9]+          { 
                    yylval = atoi(yytext); 
                    atualizar_ultimo_token("NUM", yytext);
                    return NUM; 
                }
"+"             { 
                    atualizar_ultimo_token("PLUS", yytext);
                    return PLUS; 
                }
"-"             { 
                    atualizar_ultimo_token("MINUS", yytext);
                    return MINUS; 
                }
"*"             { 
                    atualizar_ultimo_token("TIMES", yytext);
                    return TIMES; 
                }
"/"             { 
                    atualizar_ultimo_token("DIVIDE", yytext);
                    return DIVIDE; 
                }
"("             { 
                    atualizar_ultimo_token("LPAREN", yytext);
                    return LPAREN; 
                }
")"             { 
                    atualizar_ultimo_token("RPAREN", yytext);
                    return RPAREN; 
                }
[ \t]+          { /* Ignorar espaços e tabs */ }
\n              { 
                    atualizar_ultimo_token("NEWLINE", "\\n");
                    return '\n'; 
                }
.               { 
                    atualizar_ultimo_token("CARACTERE_INVALIDO", yytext);
                    printf("ERRO LÉXICO na linha %d: Caractere inválido '%s'\n", yylineno, yytext); 
                    return yytext[0]; /* Retorna o caractere para gerar erro sintático */
                }

%%