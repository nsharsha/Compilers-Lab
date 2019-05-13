%{
#include "part1.h"
%}
%option  yylineno

%%
\/\/(.*)   return SLOC;
\/\*        return OPEN;
\*\/         return CLOSE;

\".*\"             return SLOC;
("void"|"int"|"float"|"char"|"String")" "+[a-zA-Z][_a-zA-Z0-9]*" "*"(".*")"" "*[\n]*" "*"{"  ; 
"class"" "+[a-zA-Z][_a-zA-Z0-9]*" "+"extends"" "+[a-zA-Z][_a-zA-Z0-9]*" "*[\n]*" "*"{"   return INH;
"class"" "+[a-zA-Z][_a-zA-Z0-9]*" "*[\n]*" "*"{"         return CLASS;
[a-zA-Z][._a-zA-Z0-9]*" "+[a-zA-Z][_a-zA-Z0-9]*" "*"="" "*"new"" "+[a-zA-Z][.a-zA-Z0-9]*" "*"(".*")" return OBJ;
[a-zA-Z][_a-zA-Z0-9]*" "*"(".*")"" "*[\n]*" "*"{" return CONS; 
[\n] return NEW;
. ;
%%

int yywrap(void)
{
	return 1;
}

