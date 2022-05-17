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

/* Token kinds.  */
#ifndef YYUNITTOKENTYPE
# define YYUNITTOKENTYPE
  enum yyunittokentype
  {
    YYUNITEMPTY = -2,
    YYUNITEOF = 0,                 /* "end of file"  */
    YYUNITerror = 256,             /* error  */
    YYUNITUNDEF = 257,             /* "invalid token"  */
    DOUBLE = 258,                  /* DOUBLE  */
    UNIT_SHIFT = 259,              /* UNIT_SHIFT  */
    EXPONENT = 260,                /* EXPONENT  */
    SUPER_SIGN = 261,              /* SUPER_SIGN  */
    SUPER = 262,                   /* SUPER  */
    FUNCTION = 263,                /* FUNCTION  */
    ERR = 264,                     /* ERR  */
    UMINUS = 265                   /* UMINUS  */
  };
  typedef enum yyunittokentype yyunittoken_kind_t;
#endif

/* Value type.  */
#if ! defined YYUNITSTYPE && ! defined YYUNITSTYPE_IS_DECLARED
union YYUNITSTYPE
{
  UnitShift UNIT_SHIFT;                    /* UNIT_SHIFT  */
  UnitShift input;                         /* input  */
  UnitShift expr;                          /* expr  */
  UnitShift simple_expr;                   /* simple_expr  */
  double DOUBLE;                           /* DOUBLE  */
  double number;                           /* number  */
  enum parser_function FUNCTION;           /* FUNCTION  */
  int EXPONENT;                            /* EXPONENT  */
  int SUPER_SIGN;                          /* SUPER_SIGN  */
  int SUPER;                               /* SUPER  */
  int exponent;                            /* exponent  */
  int super;                               /* super  */

#line 95 "unitparse.tab.h"

};
typedef union YYUNITSTYPE YYUNITSTYPE;
# define YYUNITSTYPE_IS_TRIVIAL 1
# define YYUNITSTYPE_IS_DECLARED 1
#endif


extern YYUNITSTYPE yyunitlval;


int yyunitparse (void);


#endif /* !YY_YYUNIT_UNITPARSE_TAB_H_INCLUDED  */
