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
"if"	{ return KW_IF; }
"else"	{ return KW_ELSE; }
"else"	{ return KW_ELSE; }
"while"	{ return KW_WHILE; }
"for"	{ return KW_FOR; }
"in"	{ return KW_IN; }
"range"	{ return KW_RANGE; }
[ \t\n] { /* Nada */ }
[0-9]*	{
	yylval.num_t = atoi(yytext);
	return TK_NUM;
}
[a-zA-Z]+[0-9a-zA-Z]*	{ yylval.id_t = (char*)malloc(yyleng+1); strcpy(yylval.id_t,yytext); return TK_ID; }
\"[^"\n]*\"	{ 
	yylval.id_t = (char*)malloc(yyleng+1);
	yytext[yyleng-1]=0;
	yytext++; 
	strcpy(yylval.id_t,yytext);
	return STRING_LITERAL;
}
'[^'\n]*'	{ 
	yylval.id_t = (char*)malloc(yyleng+1);
	yytext[yyleng-1]=0;
	yytext++; 
	strcpy(yylval.id_t,yytext);
	return STRING_LITERAL;
}
<INITIAL><<EOF>>	{ yyterminate(); }
.		{ printf("Unexpected Token! %s (line:%d)",yytext,yylineno); yyterminate(); }

%%
