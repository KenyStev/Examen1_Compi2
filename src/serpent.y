%{
#include <cstdio>
#include <string>
#include "ast.h"

using namespace std;

extern int yylineno;

int yylex();

void yyerror(const char *str)
{
    printf("Line %d: %s\n", yylineno, str);
}

#define YYERROR_VERBOSE 1

Statement *input;
%}

%union {
    char *id_t;
    int  num_t;
    Statement *statement_t;
	BlockStatement *blkstatement_t;
    Expr *expr_t;
    ExprList *exprlist_t;
}

%token<num_t> TK_NUM
%token<id_t> TK_ID
%token<id_t> STRING_LITERAL
%token KW_IF KW_ELSE KW_WHILE KW_FOR KW_IN KW_RANGE KW_PRINT KW_INPUT

%token OP_EXP OP_LT OP_GT OP_LTE OP_GTE OP_NE OP_EQ
%type<expr_t> argument expra expr term exponent factor relational_expr
%type<statement_t> print_statement assign_statement opt_else if_statement for_statement
%type<statement_t> statement statement_block
%type<blkstatement_t> statement_list
%type<exprlist_t> arg_list

%%

input: statement_list { input = $1; }
;

statement_list: statement_list statement { $$ = $1; $$->add($2); }
              | statement { $$ = new BlockStatement; $$->add($1); }
;

statement: print_statement ';'
		  | assign_statement ';'
		  | for_statement
		  | if_statement
;

if_statement: KW_IF expr statement_block opt_else	{ $$ = new IfStatement($2,$3,$4); }
;

opt_else: KW_ELSE statement_block	{ $$ = $2; }
;

for_statement: KW_FOR TK_ID KW_IN KW_RANGE '(' expr ',' expr ')' statement_block	{ 
	string id = $2;
	free($2);
	$$ = new ForStatement(id,$6,$8,$10);
}
;

statement_block: '{' statement_list '}'  { $$ = $2; }
;


print_statement: KW_PRINT '(' arg_list ')' { $$ = new PrintStatement(*$3); delete $3; }
;

arg_list: arg_list ',' argument {
	    $$ = $1;
	    $$->push_back($3);
	  }
	| argument {
	    $$ = new ExprList;
	    $$->push_back($1);
	  }
;

argument: expr { $$ = $1; }
	| STRING_LITERAL {
	    string str = $1;

	    free($1);
        $$ = new StringExpr(str);
	}
;

assign_statement: TK_ID '=' expr {
				string id = $1;

				free($1);
	 			$$ = new AssignStatement(id, $3);
		}
;



expr: KW_INPUT '(' STRING_LITERAL ')'	{ $$ = new InputExpr($3); }
	| relational_expr					{ $$ = $1; }
;

relational_expr: expra OP_LTE expra 	{ $$ = new LTEExpr($1,$3); }
				| expra OP_GTE expra 	{ $$ = new GTEExpr($1,$3); }
				| expra OP_LT expra 	{ $$ = new LTExpr($1,$3); }
				| expra OP_GT expra 	{ $$ = new GTExpr($1,$3); }
				| expra OP_NE expra 	{ $$ = new NEExpr($1,$3); }
				| expra OP_EQ expra 	{ $$ = new EQExpr($1,$3); }
				| expra             				{ $$ = $1; }
;

expra: expra '+' term	{ $$ = new AddExpr($1,$3); }
    | expra '-' term	{ $$ = new SubExpr($1,$3); }
    | term              { $$ = $1; }
;

term: term '*' factor	{ $$ = new MultExpr($1,$3); }
    | term '/' factor	{ $$ = new DivExpr($1,$3); }
    | term '%' factor	{ $$ = new ModExpr($1,$3); }
    | exponent			{ $$ = $1; }
;

exponent: factor OP_EXP factor	{ $$ = new ExptExpr($1,$3); }
		| factor				{ $$ = $1; }
;

factor: '(' expr ')'    { $$ = $2; }
        | '-' factor    { $$ = new MultExpr(new NumExpr(-1), $2); }
		| TK_NUM        { $$ = new NumExpr($1); }
        | TK_ID {
            string id = $1;

            free($1);
            $$ = new IdExpr(id);
        }
;

%%
