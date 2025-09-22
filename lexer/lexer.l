%{
/* lexer.l — Flex para linguagem Python-like com ponteiros e blocos por indentação */

#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* ---------- Helpers ---------- */
static int indent_stack[1024];
static int indent_top = 0;
static int pending_dedents = 0;

/* Entramos no estado BOL (begin-of-line) sempre que emitimos NEWLINE ou no início do arquivo. */
static int bol_initialized = 0;

static int count_indent(const char* s) {
  int col = 0;
  for (const char* p = s; *p; ++p) {
    if (*p == ' ') col += 1;
    else if (*p == '\t') col += 4;   /* TAB = 4 espaços (ajuste se desejar) */
    else break;
  }
  return col;
}

static void push_indent(int n) { indent_stack[++indent_top] = n; }
static int  top_indent(void)   { return indent_stack[indent_top]; }
static void pop_indent(void)   { if (indent_top > 0) indent_top--; }

/* strdup compatível */
static char* mydup(const char* s) {
  size_t n = strlen(s);
  char* r = (char*)malloc(n+1);
  memcpy(r, s, n+1);
  return r;
}

int yywrap(void) { return 1; }
%}

/* ---------- Flex options & states ---------- */
%option noyywrap nodefault yylineno
%option nounput noinput

%x BOL       /* início lógico de linha, para calcular INDENT/DEDENT */

WS          [ \t]+
DIGITS      [0-9]+
ID          [A-Za-z_][A-Za-z0-9_]*

STR_DQ      \"([^\"\\]|\\.)*\"     /* "..." com escapes */
STR_SQ      \'([^\'\\]|\\.)*\'     /* '...' com escapes */

%%

/* ---------- BOF: preparar pilha de indentação ---------- */
^                       {
                          if (!bol_initialized) {
                            indent_top = 0;
                            indent_stack[0] = 0;
                            pending_dedents = 0;
                            bol_initialized = 1;
                            BEGIN(BOL);
                          }
                          /* não consome nada; continua fluxo normal */
                        }

/* ---------- Comentários ---------- */
"#".*                   { /* ignora comentário até o fim da linha */ }

/* ---------- NEWLINE -> devolve NEWLINE e entra em BOL ---------- */
\r?\n                   { BEGIN(BOL); return NEWLINE; }

/* ---------- Espaços no meio da linha: ignorar ---------- */
{WS}                    { /* ignora whitespace intra-linha */ }

/* ---------- Estado BOL: medir indentação, emitir INDENT/DEDENT ---------- */
<BOL>[ \t]+             {
                          int col = count_indent(yytext);
                          int top = top_indent();
                          if (col > top) {
                            push_indent(col);
                            BEGIN(INITIAL);
                            return INDENT;
                          } else if (col == top) {
                            BEGIN(INITIAL); /* nenhuma mudança de bloco */
                            /* não retorna token; segue para próximo match */
                          } else {
                            /* reduzir indentação: um ou mais DEDENT */
                            pending_dedents = 0;
                            while (indent_top > 0 && col < top_indent()) {
                              pop_indent();
                              pending_dedents++;
                            }
                            if (col != top_indent()) {
                              /* desalinhado: trate como erro léxico se quiser */
                              return INDENT_ERROR;
                            }
                            if (pending_dedents > 0) {
                              pending_dedents--;       /* consome um */
                              /* permanece em BOL para emitir múltiplos DEDENT */
                              return DEDENT;
                            }
                            BEGIN(INITIAL); /* nada a emitir */
                          }
                        }

/* Sem espaços no início da linha: talvez haja DEDENT pendente */
<BOL>.                  {
                          if (pending_dedents > 0) {
                            pending_dedents--;
                            yyless(0);      /* reprocessa este caractere depois */
                            return DEDENT;
                          }
                          BEGIN(INITIAL);
                          yyless(0);        /* reprocessa este caractere no estado normal */
                        }

/* ---------- Palavras-chave ---------- */
"if"                    { return IF; }
"elif"                  { return ELIF; }
"else"                  { return ELSE; }
"while"                 { return WHILE; }
"def"                   { return DEF; }
"return"                { return RETURN; }
"print"                 { return PRINT; }
"True"                  { yylval.i = 1; return BOOL; }
"False"                 { yylval.i = 0; return BOOL; }

/* ---------- Operadores e pontuação ---------- */
"=="                    { return EQ; }
"!="                    { return NE; }
"<="                    { return LE; }
">="                    { return GE; }
"//"                    { return FLOORDIV; }
"<"                     { return LT; }
">"                     { return GT; }
"="                     { return ASSIGN; }
"&"                     { return AMP; }      /* address-of */
"*"                     { return STAR; }     /* deref OU multiplicação (resolve no parser) */
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"/"                     { return SLASH; }
"%"                     { return PERCENT; }
":"                     { return COLON; }
","                     { return COMMA; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"."                     { return DOT; }

/* ---------- Literais ---------- */
{DIGITS}                { yylval.i = atoi(yytext); return INT; }
{STR_DQ}                { yylval.s = mydup(yytext); return STRING; }
{STR_SQ}                { yylval.s = mydup(yytext); return STRING; }

/* ---------- Identificadores ---------- */
{ID}                    { yylval.s = mydup(yytext); return NAME; }

/* ---------- EOF: emitir DEDENTs restantes ---------- */
<<EOF>>                 {
                          while (indent_top > 0) {
                            pop_indent();
                            return DEDENT;
                          }
                          return 0;
                        }

/* ---------- Caractere não reconhecido ---------- */
.                       { yylval.s = mydup(yytext); return BADCHAR; }

%%
