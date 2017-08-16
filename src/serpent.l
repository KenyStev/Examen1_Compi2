%option noyywrap
%option yylineno
%option nodefault

%x literal_string

%{
#include <cstdlib>
#include <cstring>
#include "ast.h"
#include "tokens.h"

#define YYERROR_VERBOSE 1
%}

DIGIT [0-9]
LETTER [a-zA-Z]

%%

"#".*\n { /* Do nothing */ }
"**" { return OP_EXP; }
"<=" { return OP_LTE; }
">=" { return OP_GTE; }
"!=" { return OP_NE; }
"==" { return OP_EQ; }
"<" { return OP_LT; }
">" { return OP_GT; }
"=" { return '='; }
"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"%" { return '%'; }
"("  { return '('; }
")"  { return ')'; }
"{"  { return '{'; }
"}"  { return '}'; }
","  { return ','; }
";"  { return ';'; }
"input"	{ return KW_INPUT; }
"print"	{ return KW_PRINT; }
[ \t\n] { /* Nada */ }
[a-zA-Z]+[0-9a-zA-Z]*	{ yylval.id_t = (char*)malloc(yyleng+1); strcpy(yylval.id_t,yytext); return TK_ID; }
\"[^"\n]*\"	{ 
	//printf("-->%s<--\n",yytext);
	yylval.id_t = (char*)malloc(yyleng+1);
	yytext++; 
	yytext[yyleng-2]=0;
	strcpy(yylval.id_t,yytext);
	return STRING_LITERAL;
	//BEGIN(INITIAL);
}
<INITIAL><<EOF>>	{ yyterminate(); }
.		{ printf("Unexpected Token! %s ",yytext); yyterminate(); }

%%
