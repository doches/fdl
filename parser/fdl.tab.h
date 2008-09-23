/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     NODEDEF = 258,
     FEATUREDEF = 259,
     STRING = 260,
     REGEX = 261,
     QSTRING = 262,
     PREDICATE = 263,
     TRUE = 264,
     FALSE = 265,
     TRAVERSE = 266,
     AND = 267,
     OR = 268,
     NOT = 269,
     NOT_LPAREN = 270,
     LPAREN = 271,
     RPAREN = 272,
     LBRACKET = 273,
     RBRACKET = 274,
     COLON = 275,
     EQUALS = 276,
     NOTEQUALS = 277,
     QUOTE = 278,
     LVECTOR = 279,
     RVECTOR = 280,
     COMMA = 281,
     DOT = 282,
     ALL = 283,
     NODEDESC = 284,
     EXPR = 285,
     BIND = 286,
     QUANTIFIER = 287
   };
#endif
/* Tokens.  */
#define NODEDEF 258
#define FEATUREDEF 259
#define STRING 260
#define REGEX 261
#define QSTRING 262
#define PREDICATE 263
#define TRUE 264
#define FALSE 265
#define TRAVERSE 266
#define AND 267
#define OR 268
#define NOT 269
#define NOT_LPAREN 270
#define LPAREN 271
#define RPAREN 272
#define LBRACKET 273
#define RBRACKET 274
#define COLON 275
#define EQUALS 276
#define NOTEQUALS 277
#define QUOTE 278
#define LVECTOR 279
#define RVECTOR 280
#define COMMA 281
#define DOT 282
#define ALL 283
#define NODEDESC 284
#define EXPR 285
#define BIND 286
#define QUANTIFIER 287




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

