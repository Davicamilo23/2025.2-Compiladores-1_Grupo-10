%{
/* lexer_c.l — Flex lexer para um subconjunto de C com ponteiros.
 * Produz os tokens esperados por parser/parser.y
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parser/parser.tab.h"

/* yylval é char* (vide parser.y). */
static char* mydup(const char* s){
    size_t n = strlen(s);
    char* p = (char*)malloc(n+1);
    if(!p){ perror("malloc"); exit(1); }
    memcpy(p, s, n+1);
    return p;
}

int yylineno = 1;
%}

%option noyywrap nodefault yylineno
%x COMMENT

/* ----------- Padrões ----------- */
WS       [ \t\r]+
NEWL     \n
DIG      [0-9]
IDSTART  [A-Za-z_]
IDCONT   [A-Za-z0-9_]
ESC      \\([\\'"nrt0]|x[0-9A-Fa-f]{2}|[0-7]{1,3})
CHAR     '([^\\'\n]|{ESC})'
STRING   "([^\\\"\n]|{ESC})*"

%%
/* ----------- Espaços/linhas ----------- */
{WS}                ;           /* ignora espaços/tabs */
{NEWL}+             { yylineno += yyleng; return NEWLINE; }

/* ----------- Comentários ----------- */
"//".*              ;           /* até o fim da linha */
"/*"                { BEGIN(COMMENT); }
<COMMENT>[^*\n]*    ;
<COMMENT>"*"+[^*/]  ;
<COMMENT>\n         { yylineno++; }
<COMMENT>"*"+"/"    { BEGIN(INITIAL); }

/* ----------- Pré-processador (ignora linha inteira) ----------- */
"#".*               { /* ignora diretivas por enquanto */ }

/* ----------- Palavras-chave e tipos ----------- */
"int"               { return T_INT; }
"float"             { return T_FLOAT; }
"char"              { return T_CHAR; }
"void"              { return T_VOID; }
"if"                { return IF; }
"else"              { return ELSE; }
"while"             { return WHILE; }
"return"            { return RETURN; }
"NULL"              { return T_NULL; }

/* ----------- Operadores/Delimitadores ----------- */
/* Atribuições compostas */
"+="                { return PLUSEQ; }
"-="                { return MINUSEQ; }
"*="                { return STAREQ; }
"/="                { return SLASHEQ; }
"%="                { return PERCENTEQ; }

"&&"                { return ANDAND; }
"||"                { return OROR; }
"=="                { return EQ; }
"!="                { return NE; }
"<="                { return LE; }
">="                { return GE; }
"->"                { return ARROW; }

"<"                 { return LT; }
">"                 { return GT; }
"!"                 { return NOT; }

"&"                 { return AMP; }
"*"                 { return STAR; }
"+"                 { return PLUS; }
"-"                 { return MINUS; }
"/"                 { return SLASH; }
"%"                 { return PERCENT; }
"="                 { return ASSIGN; }
"."                 { return DOT; }
","                 { return COMMA; }
";"                 { return SEMI; }
":"                 { return COLON; }

"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
"["                 { return LBRACK; }
"]"                 { return RBRACK; }

/* ----------- Literais ----------- */
{DIG}+"."{DIG}+     { yylval.s = mydup(yytext); return FCONST; }  /* float literal */
{DIG}+              { yylval.s = mydup(yytext); return ICONST; }
{STRING}            { yylval.s = mydup(yytext); return SCONST; }
{CHAR}              { yylval.s = mydup(yytext); return SCONST; }  /* trata char como string simples */

/* ----------- Identificadores ----------- */
{IDSTART}{IDCONT}*  { yylval.s = mydup(yytext); return IDENT; }

/* ----------- Qualquer outra coisa ----------- */
.                   { yylval.s = mydup(yytext); return BADCHAR; }

%%
