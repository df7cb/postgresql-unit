/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

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

#ifndef YY_YYUNIT_UNITPARSE_TAB_H_INCLUDED
# define YY_YYUNIT_UNITPARSE_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYUNITDEBUG
# if defined YYDEBUG
#if YYDEBUG
#   define YYUNITDEBUG 1
#  else
#   define YYUNITDEBUG 0
#  endif
# else /* ! defined YYDEBUG */
#  define YYUNITDEBUG 0
# endif /* ! defined YYDEBUG */
#endif  /* ! defined YYUNITDEBUG */
#if YYUNITDEBUG
extern int yyunitdebug;
#endif

/* Token type.  */
#ifndef YYUNITTOKENTYPE
# define YYUNITTOKENTYPE
  enum yyunittokentype
  {
    DOUBLE = 258,
    PREFIX = 259,
    UNIT = 260,
    EXPONENT = 261,
    ERROR = 262
  };
#endif

/* Value type.  */
#if ! defined YYUNITSTYPE && ! defined YYUNITSTYPE_IS_DECLARED

union YYUNITSTYPE
{

  /* UNIT  */
  Unit UNIT;
  /* input  */
  Unit input;
  /* dimension  */
  Unit dimension;
  /* DOUBLE  */
  double DOUBLE;
  /* PREFIX  */
  double PREFIX;
  /* dbl  */
  double dbl;
  /* maybe_prefix  */
  double maybe_prefix;
  /* EXPONENT  */
  int EXPONENT;
  /* maybe_exp  */
  int maybe_exp;
#line 89 "unitparse.tab.h" /* yacc.c:1909  */
};

typedef union YYUNITSTYPE YYUNITSTYPE;
# define YYUNITSTYPE_IS_TRIVIAL 1
# define YYUNITSTYPE_IS_DECLARED 1
#endif


extern YYUNITSTYPE yyunitlval;

int yyunitparse (void);

#endif /* !YY_YYUNIT_UNITPARSE_TAB_H_INCLUDED  */
