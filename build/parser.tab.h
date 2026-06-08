/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

#ifndef YY_YY_BUILD_PARSER_TAB_H_INCLUDED
# define YY_YY_BUILD_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    KW_AUTO = 258,                 /* KW_AUTO  */
    KW_BREAK = 259,                /* KW_BREAK  */
    KW_CASE = 260,                 /* KW_CASE  */
    KW_CHAR = 261,                 /* KW_CHAR  */
    KW_CONST = 262,                /* KW_CONST  */
    KW_CONTINUE = 263,             /* KW_CONTINUE  */
    KW_DEFAULT = 264,              /* KW_DEFAULT  */
    KW_DO = 265,                   /* KW_DO  */
    KW_DOUBLE = 266,               /* KW_DOUBLE  */
    KW_ELSE = 267,                 /* KW_ELSE  */
    KW_ENUM = 268,                 /* KW_ENUM  */
    KW_EXTERN = 269,               /* KW_EXTERN  */
    KW_FLOAT = 270,                /* KW_FLOAT  */
    KW_FOR = 271,                  /* KW_FOR  */
    KW_GOTO = 272,                 /* KW_GOTO  */
    KW_IF = 273,                   /* KW_IF  */
    KW_INT = 274,                  /* KW_INT  */
    KW_LONG = 275,                 /* KW_LONG  */
    KW_REGISTER = 276,             /* KW_REGISTER  */
    KW_RETURN = 277,               /* KW_RETURN  */
    KW_SHORT = 278,                /* KW_SHORT  */
    KW_SIGNED = 279,               /* KW_SIGNED  */
    KW_SIZEOF = 280,               /* KW_SIZEOF  */
    KW_STATIC = 281,               /* KW_STATIC  */
    KW_STRUCT = 282,               /* KW_STRUCT  */
    KW_SWITCH = 283,               /* KW_SWITCH  */
    KW_TYPEDEF = 284,              /* KW_TYPEDEF  */
    KW_UNION = 285,                /* KW_UNION  */
    KW_UNSIGNED = 286,             /* KW_UNSIGNED  */
    KW_VOID = 287,                 /* KW_VOID  */
    KW_VOLATILE = 288,             /* KW_VOLATILE  */
    KW_WHILE = 289,                /* KW_WHILE  */
    IDENT = 290,                   /* IDENT  */
    NUMBER = 291,                  /* NUMBER  */
    TK_OP_IGUAL_COMPARACAO = 292,  /* TK_OP_IGUAL_COMPARACAO  */
    TK_OP_DIFERENTE = 293,         /* TK_OP_DIFERENTE  */
    TK_OP_MENOR_IGUAL = 294,       /* TK_OP_MENOR_IGUAL  */
    TK_OP_MAIOR_IGUAL = 295,       /* TK_OP_MAIOR_IGUAL  */
    TK_OP_AND = 296,               /* TK_OP_AND  */
    TK_OP_OR = 297,                /* TK_OP_OR  */
    TK_OP_INCREMENTO = 298,        /* TK_OP_INCREMENTO  */
    TK_OP_DECREMENTO = 299,        /* TK_OP_DECREMENTO  */
    TK_OP_MAIS_IGUAL = 300,        /* TK_OP_MAIS_IGUAL  */
    TK_OP_MENOS_IGUAL = 301,       /* TK_OP_MENOS_IGUAL  */
    TK_OP_MULTIPLICACAO_IGUAL = 302, /* TK_OP_MULTIPLICACAO_IGUAL  */
    TK_OP_DIVISAO_IGUAL = 303,     /* TK_OP_DIVISAO_IGUAL  */
    TK_OP_MODULO_IGUAL = 304,      /* TK_OP_MODULO_IGUAL  */
    TK_OP_DESLOCAMENTO_ESQUERDA = 305, /* TK_OP_DESLOCAMENTO_ESQUERDA  */
    TK_OP_DESLOCAMENTO_DIREITA = 306, /* TK_OP_DESLOCAMENTO_DIREITA  */
    TK_OP_PONTEIRO_ACESSO = 307,   /* TK_OP_PONTEIRO_ACESSO  */
    TK_OP_SOMA = 308,              /* TK_OP_SOMA  */
    TK_OP_SUBTRACAO = 309,         /* TK_OP_SUBTRACAO  */
    TK_OP_MULTIPLICACAO = 310,     /* TK_OP_MULTIPLICACAO  */
    TK_OP_DIVISAO = 311,           /* TK_OP_DIVISAO  */
    TK_OP_MODULO = 312,            /* TK_OP_MODULO  */
    TK_OP_IGUAL = 313,             /* TK_OP_IGUAL  */
    TK_OP_MENOR = 314,             /* TK_OP_MENOR  */
    TK_OP_MAIOR = 315,             /* TK_OP_MAIOR  */
    TK_OP_NAO = 316,               /* TK_OP_NAO  */
    TK_OP_E_BIT = 317,             /* TK_OP_E_BIT  */
    TK_OP_OU_BIT = 318,            /* TK_OP_OU_BIT  */
    TK_OP_XOR_BIT = 319,           /* TK_OP_XOR_BIT  */
    TK_OP_NOT_BIT = 320,           /* TK_OP_NOT_BIT  */
    TK_OP_TERNARIO = 321,          /* TK_OP_TERNARIO  */
    TK_OP_DOIS_PONTOS = 322,       /* TK_OP_DOIS_PONTOS  */
    TK_OP_PONTO = 323,             /* TK_OP_PONTO  */
    TK_OP_VIRGULA = 324,           /* TK_OP_VIRGULA  */
    TK_OP_PONTO_VIRGULA = 325,     /* TK_OP_PONTO_VIRGULA  */
    TK_ABRE_PARENTESE = 326,       /* TK_ABRE_PARENTESE  */
    TK_FECHA_PARENTESE = 327,      /* TK_FECHA_PARENTESE  */
    TK_ABRE_CHAVE = 328,           /* TK_ABRE_CHAVE  */
    TK_FECHA_CHAVE = 329,          /* TK_FECHA_CHAVE  */
    TK_ABRE_COLCHETE = 330,        /* TK_ABRE_COLCHETE  */
    TK_FECHA_COLCHETE = 331,       /* TK_FECHA_COLCHETE  */
    LOWER_THAN_ELSE = 332          /* LOWER_THAN_ELSE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_BUILD_PARSER_TAB_H_INCLUDED  */
