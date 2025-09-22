%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

/* Variáveis globais para controle de erro */
extern int yylineno;
extern char *ultimo_token;
extern char *ultimo_lexema;

char *ultimo_token = NULL;
char *ultimo_lexema = NULL;

/* Função para atualizar o último token/lexema */
void atualizar_ultimo_token(const char *token, const char *lexema) {
    if (ultimo_token) free(ultimo_token);
    if (ultimo_lexema) free(ultimo_lexema);
    ultimo_token = strdup(token);
    ultimo_lexema = strdup(lexema);
}
%}

%option yylineno

%%

/* Tokens para palavras-chave */
"int"           { 
                    atualizar_ultimo_token("INT", yytext); 
                    return INT; 
                }
"float"         { 
                    atualizar_ultimo_token("FLOAT", yytext); 
                    return FLOAT; 
                }
"char"          { 
                    atualizar_ultimo_token("CHAR", yytext); 
                    return CHAR; 
                }
"if"            { 
                    atualizar_ultimo_token("IF", yytext); 
                    return IF; 
                }
"else"          { 
                    atualizar_ultimo_token("ELSE", yytext); 
                    return ELSE; 
                }
"return"        { 
                    atualizar_ultimo_token("RETURN", yytext); 
                    return RETURN; 
                }
"while"         { 
                    atualizar_ultimo_token("WHILE", yytext); 
                    return WHILE; 
                }
"for"           { 
                    atualizar_ultimo_token("FOR", yytext); 
                    return FOR; 
                }

/* Tokens para operadores e delimitadores */
[0-9]+          { 
                    yylval = atoi(yytext); 
                    atualizar_ultimo_token("NUM", yytext);
                    return NUM; 
                }
[0-9]+\.[0-9]+  { 
                    yylval = atof(yytext); 
                    atualizar_ultimo_token("FLOATNUM", yytext);
                    return FLOATNUM; 
                }

"="             { 
                    atualizar_ultimo_token("ASSIGN", yytext);
                    return ASSIGN; 
                }
"=="            { 
                    atualizar_ultimo_token("EQ", yytext);
                    return EQ; 
                }
"!="            { 
                    atualizar_ultimo_token("NEQ", yytext);
                    return NEQ; 
                }
"<"             { 
                    atualizar_ultimo_token("LT", yytext);
                    return LT; 
                }
"<="            { 
                    atualizar_ultimo_token("LE", yytext);
                    return LE; 
                }
">"             { 
                    atualizar_ultimo_token("GT", yytext);
                    return GT; 
                }
">="            { 
                    atualizar_ultimo_token("GE", yytext);
                    return GE; 
                }

"&&"            { 
                    atualizar_ultimo_token("AND", yytext);
                    return AND; 
                }
"||"            { 
                    atualizar_ultimo_token("OR", yytext);
                    return OR; 
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
"%"             { 
                    atualizar_ultimo_token("MOD", yytext);
                    return MOD; 
                }

"("             { 
                    atualizar_ultimo_token("LPAREN", yytext);
                    return LPAREN; 
                }
")"             { 
                    atualizar_ultimo_token("RPAREN", yytext);
                    return RPAREN; 
                }
"{"             { 
                    atualizar_ultimo_token("LBRACE", yytext);
                    return LBRACE; 
                }
"}"             { 
                    atualizar_ultimo_token("RBRACE", yytext);
                    return RBRACE; 
                }
","             { 
                    atualizar_ultimo_token("COMMA", yytext);
                    return COMMA; 
                }
";"             { 
                    atualizar_ultimo_token("SEMICOLON", yytext);
                    return SEMICOLON; 
                }

/* Ignorar espaços e quebras de linha */
[ \t\n]+        { /* Ignorar espaços e tabs */ }

/* Ignorar comentários */
"//".*          { /* Ignorar comentários de linha */ }
"/\*.*\*/"      { /* Ignorar comentários de bloco */ }

/* Identificadores (variáveis e funções) */
[a-zA-Z_][a-zA-Z0-9_]* { 
                    yylval = strdup(yytext); 
                    atualizar_ultimo_token("IDENTIFIER", yytext);
                    return IDENTIFIER; 
                }

/* Erro léxico */
.               { 
                    atualizar_ultimo_token("CARACTERE_INVALIDO", yytext);
                    printf("ERRO LÉXICO na linha %d: Caractere inválido '%s'\n", yylineno, yytext); 
                    return yytext[0]; /* Retorna o caractere para gerar erro sintático */
                }

%%