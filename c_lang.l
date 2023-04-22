%option noyywrap
%option noinput
%option nounput

%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "c_lang.tab.h"

	extern int lineNumber;
%}

alpha [a-zA-Z]
digit [0-9]
alphanum {alpha}|{digit}
dec {digit}+
hex 0x[0-9A-Fa-f]+

%%
{dec} { yylval.num = atoi(yytext); return tNB; }
{hex} { yylval.num = (int) strtol(yytext, NULL, 0); return tNB; }

"if" { return tIF; }
"else" { return tELSE ; }
"while" { return tWHILE; }
"print" { return tPRINT; }
"return" { return tRETURN; }
"int" { return tINT; }
"void" { return tVOID; }

{alpha}{alphanum}* { yylval.str = strdup(yytext); return tID; }

[\n] { lineNumber++; }
[ \t\r] { /* ignore whitespace */ }
"//".* { /* ignore single-line comments */ { printf("comment\n"); } }
"/*"([^*]|\n|(\*+[^*/]))*"*/" { /* ignore multiline comments */ { printf("multiline comment\n"); } }

"+" { return tADD; }
"-" { return tSUB; }
"*" { return tMUL; }
"/" { return tDIV; }
"<" { return tLT; }
">" { return tGT; }
"!=" { return tNE; }
"==" { return tEQ; }
">=" { return tGE; }
"<=" { return tLE; }
"=" { return tASSIGN; }
"&&" { return tAND; }
"||" { return tOR; }

"!" { return tNOT; }
"{" { return tLBRACE; }
"}" { return tRBRACE; }
"(" { return tLPAR; }
")" { return tRPAR; }
";" { return tSEMI; }
"," { return tCOMMA; }

. { fprintf(stderr, "Invalid character: %s\n", yytext); }
