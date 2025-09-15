%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern int yylineno;
%}

%option noyywrap nodefault yylineno

DIGIT         [0-9]
ID_START      [A-Za-z_]
ID_CONT       [A-Za-z0-9_]

%%

[ \t]+        { /* ignore whitespace */ }
\n            { return NEWLINE; }
"#"[^\n]*     { /* ignore comments */ }

"def"         { return DEF; }
"if"          { return IF; }
"elif"        { return ELIF; }
"else"        { return ELSE; }
"while"       { return WHILE; }
"return"      { return RETURN; }
"print"       { return PRINT; }
"and"         { return AND; }
"or"          { return OR; }
"not"         { return NOT; }
"True"        { return TRUE; }
"False"       { return FALSE; }
"None"        { return NONE; }

{ID_START}{ID_CONT}*  { yylval.s = strdup(yytext); return ID; }
{DIGIT}+              { yylval.s = strdup(yytext); return INT_LIT; }
\"[^\"]*\"            { yylval.s = strdup(yytext); return STRING_LIT; }

"=="          { return EQEQ; }
"!="          { return NE; }
"<="          { return LE; }
">="          { return GE; }
"<"           { return LT; }
">"           { return GT; }
":"           { return COLON; }
","           { return COMMA; }
"("           { return LPAREN; }
")"           { return RPAREN; }
"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return STAR; }
"//"          { return SLASHSLASH; }
"%"           { return PERCENT; }
"="           { return ASSIGN; }

"    "        { return INDENT; }

.             { fprintf(stderr, "Unexpected character: %s\n", yytext); }

%%
