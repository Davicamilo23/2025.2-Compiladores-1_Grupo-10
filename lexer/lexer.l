%{
/* lexer.l — Flex para linguagem Python-like com:
 * - Blocos por indentação: NEWLINE, INDENT, DEDENT (pilha de indentação)
 * - Comentários: '# ...'
 * - Palavras-chave: if, elif, else, while, def, return, print, True, False
 * - Literais: inteiros (INT) e strings (STRING, '...' e "...")
 * - Identificadores: NAME
 * - Operadores: ==, !=, <=, >=, <, >, =, +, -, *, /, //, %, &, :, ,, (, ), .
 * - Ponteiros: & (AMP), * (STAR) — papel unário/aritmético decidido no parser
 * - Rastreamento de erro: yylineno, ultimo_token, ultimo_lexema
 */

#include "parser.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

/* ---------- Estado de indentação ---------- */
static int indent_stack[1024];
static int indent_top = 0;
static int pending_dedents = 0;
static int bol_initialized = 0; /* já inicializamos pilha no BOF? */

/* ---------- Rastreamento para mensagens de erro detalhadas ---------- */
int yylineno;                 /* %option yylineno já cuida disso */
char *ultimo_token = NULL;
char *ultimo_lexema = NULL;

static void atualizar_ultimo_token(const char *token, const char *lexema) {
  if (ultimo_token) { free(ultimo_token); ultimo_token = NULL; }
  if (ultimo_lexema) { free(ultimo_lexema); ultimo_lexema = NULL; }
  if (token)  { ultimo_token  = strdup(token); }
  if (lexema) { ultimo_lexema = strdup(lexema); }
}

/* ---------- Utilidades ---------- */
static int count_indent(const char* s) {
  int col = 0;
  for (const char* p = s; *p; ++p) {
    if (*p == ' ') col += 1;
    else if (*p == '\t') col += 4;   /* ajuste se preferir outro custo */
    else break;
  }
  return col;
}

static void push_indent(int n) { indent_stack[++indent_top] = n; }
static int  top_indent(void)   { return indent_stack[indent_top]; }
static void pop_indent(void)   { if (indent_top > 0) indent_top--; }

static char* mydup(const char* s) {
  size_t n = strlen(s);
  char* r = (char*)malloc(n+1);
  memcpy(r, s, n+1);
  return r;
}

int yywrap(void) { return 1; }
%}

/* ---------- Opções / estados ---------- */
%option noyywrap nodefault yylineno
%option nounput noinput

%x BOL       /* início lógico de linha p/ computar INDENT/DEDENT */

WS          [ \t]+
DIGITS      [0-9]+
ID          [A-Za-z_][A-Za-z0-9_]*

STR_DQ      \"([^\"\\]|\\.)*\"     /* "..." com escapes */
STR_SQ      \'([^\'\\]|\\.)*\'     /* '...' com escapes */

%%

/* ---------- BOF: preparar a pilha de indentação e entrar em BOL ---------- */
^                       {
                          if (!bol_initialized) {
                            indent_top = 0;
                            indent_stack[0] = 0; /* nível base = 0 */
                            pending_dedents = 0;
                            bol_initialized = 1;
                            BEGIN(BOL);
                          }
                          /* não consome; próximos matches tratam a linha */
                        }

/* ---------- Comentários ---------- */
"#".*                   { /* ignora até o fim da linha */ }

/* ---------- NEWLINE: sempre retorna NEWLINE e vai para BOL ---------- */
\r?\n                   {
                          atualizar_ultimo_token("NEWLINE", "\\n");
                          BEGIN(BOL);
                          return NEWLINE;
                        }

/* ---------- Espaços intra-linha: ignorar ---------- */
{WS}                    { /* ignora */ }

/* ---------- Início de linha (BOL): medir indent e emitir INDENT/DEDENT ---------- */
<BOL>[ \t]+             {
                          int col = count_indent(yytext);
                          int top = top_indent();

                          if (col > top) {
                            push_indent(col);
                            atualizar_ultimo_token("INDENT", yytext);
                            BEGIN(INITIAL);
                            return INDENT;
                          } else if (col == top) {
                            BEGIN(INITIAL); /* nada a emitir */
                          } else {
                            /* reduzir indentação → possivelmente vários DEDENT */
                            pending_dedents = 0;
                            while (indent_top > 0 && col < top_indent()) {
                              pop_indent();
                              pending_dedents++;
                            }
                            if (col != top_indent()) {
                              /* desalinhado: token especial (declare no parser se quiser tratar) */
                              atualizar_ultimo_token("INDENT_ERROR", yytext);
                              return INDENT_ERROR;
                            }
                            if (pending_dedents > 0) {
                              pending_dedents--;
                              atualizar_ultimo_token("DEDENT", "<auto>");
                              /* permanecemos em BOL até zerar pendentes */
                              return DEDENT;
                            }
                            BEGIN(INITIAL);
                          }
                        }

/* Sem espaços no início da linha: antes de processar o 1º char, despeje DEDENTs pendentes */
<BOL>.                  {
                          if (pending_dedents > 0) {
                            pending_dedents--;
                            yyless(0);                          /* reprocessa este char depois */
                            atualizar_ultimo_token("DEDENT", "<auto>");
                            return DEDENT;
                          }
                          BEGIN(INITIAL);
                          yyless(0);                            /* reprocessa no estado normal */
                        }

/* ---------- Palavras-chave ---------- */
"if"                    { atualizar_ultimo_token("IF", yytext);    return IF; }
"elif"                  { atualizar_ultimo_token("ELIF", yytext);  return ELIF; }
"else"                  { atualizar_ultimo_token("ELSE", yytext);  return ELSE; }
"while"                 { atualizar_ultimo_token("WHILE", yytext); return WHILE; }
"def"                   { atualizar_ultimo_token("DEF", yytext);   return DEF; }
"return"                { atualizar_ultimo_token("RETURN", yytext);return RETURN; }
"print"                 { atualizar_ultimo_token("PRINT", yytext); return PRINT; }
"True"                  { yylval.i = 1; atualizar_ultimo_token("BOOL", yytext); return BOOL; }
"False"                 { yylval.i = 0; atualizar_ultimo_token("BOOL", yytext); return BOOL; }

/* ---------- Operadores / pontuação ---------- */
"=="                    { atualizar_ultimo_token("EQ", yytext);        return EQ; }
"!="                    { atualizar_ultimo_token("NE", yytext);        return NE; }
"<="                    { atualizar_ultimo_token("LE", yytext);        return LE; }
">="                    { atualizar_ultimo_token("GE", yytext);        return GE; }
"//"                    { atualizar_ultimo_token("FLOORDIV", yytext);  return FLOORDIV; }
"<"                     { atualizar_ultimo_token("LT", yytext);        return LT; }
">"                     { atualizar_ultimo_token("GT", yytext);        return GT; }
"="                     { atualizar_ultimo_token("ASSIGN", yytext);    return ASSIGN; }
"&"                     { atualizar_ultimo_token("AMP", yytext);       return AMP; }     /* addr-of */
"*"                     { atualizar_ultimo_token("STAR", yytext);      return STAR; }    /* deref/mul (parser decide) */
"+"                     { atualizar_ultimo_token("PLUS", yytext);      return PLUS; }
"-"                     { atualizar_ultimo_token("MINUS", yytext);     return MINUS; }
"/"                     { atualizar_ultimo_token("SLASH", yytext);     return SLASH; }
"%"                     { atualizar_ultimo_token("PERCENT", yytext);   return PERCENT; }
":"                     { atualizar_ultimo_token("COLON", yytext);     return COLON; }
","                     { atualizar_ultimo_token("COMMA", yytext);     return COMMA; }
"("                     { atualizar_ultimo_token("LPAREN", yytext);    return LPAREN; }
")"                     { atualizar_ultimo_token("RPAREN", yytext);    return RPAREN; }
"."                     { atualizar_ultimo_token("DOT", yytext);       return DOT; }

/* ---------- Literais ---------- */
{DIGITS}                { yylval.i = atoi(yytext); atualizar_ultimo_token("INT", yytext);    return INT; }
{STR_DQ}                { yylval.s = mydup(yytext); atualizar_ultimo_token("STRING", yytext); return STRING; }
{STR_SQ}                { yylval.s = mydup(yytext); atualizar_ultimo_token("STRING", yytext); return STRING; }

/* ---------- Identificadores ---------- */
{ID}                    { yylval.s = mydup(yytext); atualizar_ultimo_token("NAME", yytext); return NAME; }

/* ---------- EOF: emitir DEDENTs restantes ---------- */
<<EOF>>                 {
                          if (pending_dedents > 0) {
                            pending_dedents--;
                            atualizar_ultimo_token("DEDENT", "<eof>");
                            return DEDENT;
                          }
                          while (indent_top > 0) {
                            pop_indent();
                            atualizar_ultimo_token("DEDENT", "<eof>");
                            return DEDENT;          /* o parser chamará yylex() de novo e cairá aqui até zerar */
                          }
                          atualizar_ultimo_token("EOF", "<eof>");
                          return 0;
                        }

/* ---------- Caractere não reconhecido ---------- */
.                       { yylval.s = mydup(yytext); atualizar_ultimo_token("BADCHAR", yytext); return BADCHAR; }

%%
