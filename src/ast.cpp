#include <cstdio>
#include <iostream>
#include "ast.h"

using namespace std;

map<string, int> vars;

int expt(int p, unsigned int q)
{
    int r = 1;

    while (q != 0) {
        if (q % 2 == 1) {    // q is odd
            r *= p;
            q--;
        }
        p *= p;
        q /= 2;
    }

    return r;
}

// int BinaryExpr::evaluate()
// {
//     switch(getKind())
//     {
//         case ADD_EXPR: return expr1->evaluate() + expr2->evaluate();
//         case SUB_EXPR: return expr1->evaluate() - expr2->evaluate();
//         case MULT_EXPR: return expr1->evaluate() * expr2->evaluate();
//         case DIV_EXPR: return expr1->evaluate() / expr2->evaluate();
//         case MOD_EXPR: return expr1->evaluate() % expr2->evaluate();
//         case EXPT_EXPR: return expt(expr1->evaluate(),expr2->evaluate());
//     }
// }

int ExptExpr::evaluate(){
    return expt(expr1->evaluate(),expr2->evaluate());
}

int InputExpr::evaluate(){
    printf("%s", msj);
    int val;
    cin>>val;
    return val;
  }

void BlockStatement::execute()
{
    list<Statement *>::iterator it = stList.begin();

    while (it != stList.end()) {
        Statement *st = *it;

        st->execute();
        it++;
    }
}

void AssignStatement::execute()
{
    vars[id] = expr->evaluate();
}

void PrintStatement::execute()
{
    for(list<Expr*>::iterator i = espress.begin(); i!=espress.end(); i++)
    {
        if((*i)->getKind()==STRING_EXPR)
            printf("%s", ((StringExpr*)(*i))->str.c_str());
        else
            printf("%d\n", (*i)->evaluate());

    }
}

void IfStatement::execute()
{
    if(expr->evaluate())
        ifStmt->execute();
    else if(elseStmt)
        elseStmt->execute();
}

void ForStatement::execute()
{
    vars[id] = from->evaluate();
    int toVal = to->evaluate();
    while(vars[id] < toVal)
    {
        block->execute();
        vars[id]++;
    }
}

void WhileStatement::execute()
{
    while(expr->evaluate())
        block->execute();
}