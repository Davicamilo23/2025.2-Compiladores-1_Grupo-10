%{
/*
 * scanner.l — Lexer (Flex) para uma linguagem Python-like com blocos por indentação.
 *
 * IDEA-CHAVE:
 *  - O lexer converte início de linha em tokens estruturais: NEWLINE / INDENT / DEDENT.
 *  - A indentação pode misturar espaços e tabs. Regras:
 *      espaço -> avança 1 coluna
 *      tab    -> avança até o próximo múltiplo de 8 (col = ((col/8)+1)*8)
 *  - Mantemos uma PILHA de níveis de coluna (indent_stack). Ao iniciar um bloco, empilha;
 *    ao reduzir indentação, emitimos um ou mais DEDENTs até igualar o nível anterior.
 *
 * COMO FUNCIONA:
 *  1) A cada NEWLINE, marcamos at_line_start=1.
 *  2) No primeiro char NÃO-NOVA-LINHA da linha, antes de tokenizar, entramos no estado
 *     INDENTING para medir espaços+tabs do começo de linha e gerar (se preciso) INDENT/DEDENT.
 *  3) Depois disso, tokenizamos normalmente (identificadores, literais, operadores etc.).
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <string>
#include "parser.tab.h"   /* tokens do Bison */

static std::vector<int> indent_stack = {0}; /* nível de coluna inicial = 0 */
static int pending_dedents = 0;             /* DEDENTs ainda não emitidos */
static int at_line_start = 1;               /* estamos no início de uma nova linha? */

extern int yylineno; /* habilitado por %option yylineno */

/* Mensagem de erro léxico simples */
static void lex_error(const char* msg) {
  fprintf(stderr, "[LEX] linha %d: %s\n", yylineno, msg);
}
%}

/* Opções do Flex */
%option noyywrap nodefault yylineno
%option nounput noinput

/* Estado exclusivo para medir indentação no começo de linha */
%x INDENTING

/* Macros */
NEWLINE       \n
DIGIT         [0-9]
ID_START      [A-Za-z_]
ID_CONT       [A-Za-z0-9_]
MIDWS         [ \t\r\f\v]+           /* whitespace no MEIO da linha (ignorar) */
STRCHAR       ([^\"\\]|\\.|\\\")

/* -------------------------------------------------------------------------- */
/* REGRAS                                                                      */
/* -------------------------------------------------------------------------- */
%%

/* Priorizar DEDENTs pendentes antes de qualquer outro token comum */
<INITIAL>.  {
  if (pending_dedents > 0) {
    yyless(0);            /* não consome o caractere; emite DEDENT primeiro */
    pending_dedents--;
    return DEDENT;
  }
  yyless(0);              /* reprocessar o mesmo caractere por outras regras */
  BEGIN(INITIAL);
}

/* Comentários: ignorar o conteúdo, mas NÃO consumir o NEWLINE (a regra de NEWLINE cuida disso) */
"#"[^\n]*    { /* ignora o comentário até o fim da linha */ }

/* NEWLINE: final de statement simples; ativa at_line_start para medir indent da próxima linha */
{NEWLINE}+   { at_line_start = 1; return NEWLINE; }

/* Espaços/tabs no meio da linha (fora da indentação do começo): ignorar */
{MIDWS}      { /* ignora */ }

/* Se estamos no COMEÇO da linha e vemos algo que não é NEWLINE, medir indentação antes */
<INITIAL>[^\n] {
  if (at_line_start) {
    yyless(0);            /* recua um caractere e vai medir indentação */
    BEGIN(INDENTING);
  }
}

/* --------------------------- ESTADO INDENTING --------------------------- */
/* Aqui aceitamos QUALQUER mistura de ' ' e '\t' no começo da linha.
 * Convertemos em "colunas" como o Python: tab pula até o próximo múltiplo de 8.
 */
<INDENTING>{
  [ \t]* {
    /* Calcula a coluna final da indentação */
    int col = 0;
    for (int i = 0; i < yyleng; i++) {
      if (yytext[i] == ' ') {
        col += 1;
      } else if (yytext[i] == '\t') {
        col = ((col / 8) + 1) * 8;
      }
    }

    at_line_start = 0;
    BEGIN(INITIAL);

    int top = indent_stack.back();
    if (col > top) {
      /* Aumentou indentação: um INDENT e empilha nível */
      indent_stack.push_back(col);
      return INDENT;
    } else if (col < top) {
      /* Diminuiu indentação: emitir DEDENTs até igualar */
      while (!indent_stack.empty() && col < indent_stack.back()) {
        indent_stack.pop_back();
        pending_dedents++;
      }
      if (indent_stack.empty() || indent_stack.back() != col) {
        lex_error("indentação inválida: nível não corresponde a um bloco aberto");
        return ERROR;
      }
      /* Emite um DEDENT agora; os demais ficam pendentes */
      pending_dedents--;
      return DEDENT;
    }
    /* col == top -> mesmo nível: nada a emitir, segue tokenização normal */
  }

  /* Linha vazia (só \n): mantém nível; apenas gera NEWLINE */
  \r?\n       { at_line_start = 1; BEGIN(INITIAL); return NEWLINE; }

  /* EOF enquanto medindo indentação: drena DEDENTs remanescentes */
  <<EOF>>     {
    while (indent_stack.size() > 1) {
      indent_stack.pop_back();
      pending_dedents++;
    }
    if (pending_dedents > 0) { pending_dedents--; return DEDENT; }
    return 0; /* EOF */
  }

  /* Primeiro char não-whitespace da linha: voltar ao INITIAL para tokenizar normal */
  .           { at_line_start = 0; BEGIN(INITIAL); yyless(0); }
}

/* --------------------------- PALAVRAS-CHAVE --------------------------- */
"def"     { return DEF; }
"if"      { return IF; }
"elif"    { return ELIF; }
"else"    { return ELSE; }
"while"   { return WHILE; }
"return"  { return RETURN; }
"print"   { return PRINT; }
"and"     { return AND; }
"or"      { return OR; }
"not"     { return NOT; }
"True"    { return TRUE; }
"False"   { return FALSE; }
"None"    { return NONE; }

/* --------------------------- IDENTIFICADORES & LITERAIS --------------------------- */
{ID_START}{ID_CONT}*  { yylval.s = strdup(yytext); return ID; }
{DIGIT}+              { yylval.s = strdup(yytext); return INT_LIT; }
\"{STRCHAR}*\"        { yylval.s = strdup(yytext); return STRING_LIT; }

/* --------------------------- OPERADORES / DELIMITADORES --------------------------- */
"=="  { return EQEQ; }
"!="  { return NE; }
"<="  { return LE; }
">="  { return GE; }
"<"   { return LT; }
">"   { return GT; }
":"   { return COLON; }
","   { return COMMA; }
"("   { return LPAREN; }
")"   { return RPAREN; }
"+"   { return PLUS; }
"-"   { return MINUS; }
"*"   { return STAR; }
"//"  { return SLASHSLASH; }
"%"   { return PERCENT; }
"="   { return ASSIGN; }

/* --------------------------- EOF (fora do INDENTING) --------------------------- */
<<EOF>> {
  /* Se EOF ocorrer com blocos abertos, emita DEDENTs até voltar ao nível 0 */
  while (indent_stack.size() > 1) {
    indent_stack.pop_back();
    pending_dedents++;
  }
  if (pending_dedents > 0) { pending_dedents--; return DEDENT; }
  return 0;
}
%%
