/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Skeleton interface for Bison GLR parsers in C

   Copyright (C) 2002-2015, 2018-2021 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 4 "parser.y"

  #include "../src/tabela_simbolos/tipos.h"
  typedef struct Ast Ast; 

#line 49 "parser.tab.h"

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    T_INT = 258,                   /* T_INT  */
    T_CHAR = 259,                  /* T_CHAR  */
    T_VOID = 260,                  /* T_VOID  */
    T_NULL = 261,                  /* T_NULL  */
    T_FLOAT = 262,                 /* T_FLOAT  */
    T_STATIC = 263,                /* T_STATIC  */
    IF = 264,                      /* IF  */
    ELSE = 265,                    /* ELSE  */
    WHILE = 266,                   /* WHILE  */
    FOR = 267,                     /* FOR  */
    RETURN = 268,                  /* RETURN  */
    ANDAND = 269,                  /* ANDAND  */
    OROR = 270,                    /* OROR  */
    NOT = 271,                     /* NOT  */
    EQ = 272,                      /* EQ  */
    NE = 273,                      /* NE  */
    LT = 274,                      /* LT  */
    LE = 275,                      /* LE  */
    GT = 276,                      /* GT  */
    GE = 277,                      /* GE  */
    AMP = 278,                     /* AMP  */
    STAR = 279,                    /* STAR  */
    PLUS = 280,                    /* PLUS  */
    MINUS = 281,                   /* MINUS  */
    SLASH = 282,                   /* SLASH  */
    PERCENT = 283,                 /* PERCENT  */
    ASSIGN = 284,                  /* ASSIGN  */
    PLUSEQ = 285,                  /* PLUSEQ  */
    MINUSEQ = 286,                 /* MINUSEQ  */
    STAREQ = 287,                  /* STAREQ  */
    SLASHEQ = 288,                 /* SLASHEQ  */
    PERCENTEQ = 289,               /* PERCENTEQ  */
    DOT = 290,                     /* DOT  */
    ARROW = 291,                   /* ARROW  */
    COMMA = 292,                   /* COMMA  */
    SEMI = 293,                    /* SEMI  */
    COLON = 294,                   /* COLON  */
    LPAREN = 295,                  /* LPAREN  */
    RPAREN = 296,                  /* RPAREN  */
    LBRACE = 297,                  /* LBRACE  */
    RBRACE = 298,                  /* RBRACE  */
    LBRACK = 299,                  /* LBRACK  */
    RBRACK = 300,                  /* RBRACK  */
    ICONST = 301,                  /* ICONST  */
    FCONST = 302,                  /* FCONST  */
    SCONST = 303,                  /* SCONST  */
    IDENT = 304,                   /* IDENT  */
    BADCHAR = 305,                 /* BADCHAR  */
    UAMP = 306,                    /* UAMP  */
    USTAR = 307,                   /* USTAR  */
    UMINUS = 308                   /* UMINUS  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 44 "parser.y"

  int    ival;
  char*  sval;
  int    n;
  Tipo   tipo;
  char*  nome_var;
  Ast*   ast;

#line 128 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
