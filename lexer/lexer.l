%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../parser/parser.tab.h"

#define RET(tok) do { atualizar_token(#tok, yytext); \
fprintf(stderr, "[LEX] %s '%s'\n", #tok, yytext); \
return tok; } while (0)

static char* mydup(const char* s){
size_t n = strlen(s);
char* p = (char*)malloc(n+1);
if(!p){ perror("malloc"); exit(1); }
memcpy(p, s, n+1);
return p;
}

char *ultimo_token = NULL;
char *ultimo_lexema = NULL;

void atualizar_token(const char *token, const char *lexema) {
if (ultimo_token) free(ultimo_token);
if (ultimo_lexema) free(ultimo_lexema);
ultimo_token = mydup(token);
ultimo_lexema = mydup(lexema);
}
%}

%option noyywrap nodefault yylineno
%option noinput nounput

%x COMMENT

WS       [ \t\r]+
NEWL     \n
DIG      [0-9]
IDSTART  [A-Za-z_]
IDCONT   [A-Za-z0-9_]
ESC      \\([\\'"nrt0]|x[0-9A-Fa-f]{2}|[0-7]{1,3})
CHAR     '([^\\'\n]|{ESC})'


%%
{WS} ;
{NEWL}+ ;

"//".* ;
"/*" { BEGIN(COMMENT); }
<COMMENT>[^*\n]* ;
<COMMENT>"*"+[^*/] ;
<COMMENT>\n { yylineno++; }
<COMMENT>"*"+"/" { BEGIN(INITIAL); }

"#".* { }

"int" { RET(T_INT); }
"float" { RET(T_FLOAT); }
"char" { RET(T_CHAR); }
"void" { RET(T_VOID); }
"if" { RET(IF); }
"else" { RET(ELSE); }
"while" { RET(WHILE); }
"for" { RET(FOR); }
"return" { RET(RETURN); }
"NULL" { RET(T_NULL); }
"static"     { RET(T_STATIC); }

"+=" { RET(PLUSEQ); }
"-=" { RET(MINUSEQ); }
"*=" { RET(STAREQ); }
"/=" { RET(SLASHEQ); }
"%=" { RET(PERCENTEQ); }

"&&" { RET(ANDAND); }
"||" { RET(OROR); }
"==" { RET(EQ); }
"!=" { RET(NE); }
"<=" { RET(LE); }
">=" { RET(GE); }
"->" { RET(ARROW); }

"<" { RET(LT); }
">" { RET(GT); }
"!" { RET(NOT); }
"&" { RET(AMP); }
"*" { RET(STAR); }
"+" { RET(PLUS); }
"-" { RET(MINUS); }
"/" { RET(SLASH); }
"%" { RET(PERCENT); }
"=" { RET(ASSIGN); }
"." { RET(DOT); }
"," { RET(COMMA); }
";" { RET(SEMI); }
":" { RET(COLON); }

"(" { RET(LPAREN); }
")" { RET(RPAREN); }
"{" { RET(LBRACE); }
"}" { RET(RBRACE); }
"[" { RET(LBRACK); }
"]" { RET(RBRACK); }

{DIG}+"."{DIG}+ { yylval.sval = mydup(yytext); RET(FCONST); }
{DIG}+ { yylval.ival = atoi(yytext); RET(ICONST); }
\"[^\"]*\"  { yylval.sval = mydup(yytext); RET(SCONST); }
{CHAR} { yylval.sval = mydup(yytext); RET(SCONST); }

{IDSTART}{IDCONT}* { yylval.sval = mydup(yytext); RET(IDENT); }

. { yylval.sval = mydup(yytext); RET(BADCHAR); }  

%%
