%{


#include "part5.h"

#include "g.tab.h"

%}
%option yylineno	
%%

"#include".*			return LIBRARY;
\/\/(.*) {};					
\/\*[^"*/"]*\*\/ {};
"main"					return MAIN;
"return" 				return RETURN;
"int"					return INT;
"float"					return FLOAT;
"void"					return VOID;
"else if"				return ELSEIF;
"else"					return ELSE;
"if"					return IF;
"while"					return WHILE;
"for"					return FOR;
"switch"				return SWITCH;
"case"					return CASE;
"break"					return BREAK;
"continue"				return CONTINUE;
"default"				return DEFAULT;
"<="					return LESSEQUAL;
">="					return GREATEQUAL;	//token for relational operators
"<"						return LESS;	//token for less than or open angle brace
">"						return GREAT;
"["						return SQOPEN;
"]"						return SQCLOSE;
"{"						return CURLYOPEN;
"}"						return CURLYCLOSE;
"("                     return OPEN;	//token for open brace
")"                     return CLOSE;	//token for close brace
"=="					return EQUAL;
"="						return ASSIGN;
"!="					return NOTEQUAL;	//token for equality operators
"+"               		return PLUS;	//token for arithematic operators
"-"						return MINUS;
"%"						return MOD;
"*"						return INTO;
"/"						return DIV;
"&&"					return AND;
"||"					return OR;
":"						return COLON;	
","						return COMMA;
";" 					return SEMI;	//token for COMMA
[_a-zA-Z][_a-zA-Z0-9]*	{strcpy(yylval.s,yytext); return ID;}	//token for table name or any attribute name
[0-9]+"."[0-9]+			{ strcpy(yylval.s,yytext);  return FLOATNUM;}
[0-9]+                  { strcpy(yylval.s,yytext);	return NUMBER;}	//token for any number
[\n]					;	
.						;	//everything else

%%


int yywrap(void)
{
	return 1;	//if yywrap returns 1 then yylex returns 0 which means the end of file
}
