%{
#include "parser.tab.h"
#include <stdlib.h>
%}

%%

/* Tokens para identificadores e palavras-chave */
"int"           { return INT; }
"float"         { return FLOAT; }
"char"          { return CHAR; }
"if"            { return IF; }
"else"          { return ELSE; }
"return"        { return RETURN; }
"while"         { return WHILE; }
"for"           { return FOR; }
/* etc. */

[0-9]+          { yylval = atoi(yytext); return NUM; }  /* Para inteiros */
[0-9]+\.[0-9]+  { yylval = atof(yytext); return FLOATNUM; }  /* Para floats */

"="             { return ASSIGN; }
"=="            { return EQ; }
"!="            { return NEQ; }
"<"             { return LT; }
"<="            { return LE; }
">"             { return GT; }
">="            { return GE; }

"&&"            { return AND; }
"||"            { return OR; }

"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"%"             { return MOD; }

"("             { return LPAREN; }
")"             { return RPAREN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
","             { return COMMA; }
";"             { return SEMICOLON; }

[ \t\n]+        { /* Ignorar espaços em branco e quebras de linha */ }
"//".*          { /* Ignorar comentários de linha */ }
"/\*.*\*/"      { /* Ignorar comentários de bloco */ }

[a-zA-Z_][a-zA-Z0-9_]* { yylval = strdup(yytext); return IDENTIFIER; }  /* Para variáveis e funções */

.               { printf("Caractere inválido: %s\n", yytext); }

%%