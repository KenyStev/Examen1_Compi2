#ifndef _AST_H_
#define _AST_H_

#include <string>
#include <list>
#include <map>

using namespace std;

extern map<string, int> vars;

enum ExprKind {
  LT_EXPR,
  LTE_EXPR,
  GT_EXPR,
  GTE_EXPR,
  NE_EXPR,
  EQ_EXPR,
  ADD_EXPR,
  SUB_EXPR,
  MULT_EXPR,
  DIV_EXPR,
  MOD_EXPR,
  EXPT_EXPR,
  NUM_EXPR,
  ID_EXPR,
  STRING_EXPR,
  INPUT_EXPR
};

class Expr;
typedef list<Expr*> ExprList;

class Expr {
public:
    virtual int evaluate() = 0;
    virtual int getKind() = 0;
    bool isA(int kind) { return (getKind() == kind); }
};

class BinaryExpr: public Expr {
public:
    BinaryExpr(Expr *expr1, Expr *expr2) {
        this->expr1 = expr1;
        this->expr2 = expr2;
    }

    Expr *expr1;
    Expr *expr2;

    // int evaluate();
};

#define DEFINE_BINARY_EXPR(name,NAME,sym) \
  class name##Expr : public BinaryExpr \
  { \
  public: \
    name##Expr(Expr *expr1, Expr *expr2) : BinaryExpr(expr1,expr2) {} \
    int evaluate(){ return expr1->evaluate() sym expr2->evaluate(); } \
    int getKind(){ return NAME##_EXPR; } \
  };

//Expr
DEFINE_BINARY_EXPR(Add,ADD,+);
DEFINE_BINARY_EXPR(Sub,SUB,-);
DEFINE_BINARY_EXPR(Mult,MULT,*);
DEFINE_BINARY_EXPR(Div,DIV,/);
DEFINE_BINARY_EXPR(Mod,MOD,%);
// DEFINE_BINARY_EXPR(Expt,EXPT,**);
//Logical
DEFINE_BINARY_EXPR(GTE,GTE,>=);
DEFINE_BINARY_EXPR(LTE,LTE,<=);
DEFINE_BINARY_EXPR(GT,GT,>);
DEFINE_BINARY_EXPR(LT,LT,<);
DEFINE_BINARY_EXPR(NE,NE,!=);
DEFINE_BINARY_EXPR(EQ,EQ,==);

class ExptExpr : public BinaryExpr
{
public:
  ExptExpr(Expr *expr1, Expr *expr2) : BinaryExpr(expr1,expr2) {}
  int evaluate();
  int getKind(){return EXPT_EXPR; }
};

class InputExpr : public Expr
{
public:
  InputExpr(char*msj){ this->msj = msj; }
  int evaluate();
  int getKind(){ return INPUT_EXPR; }
  char*msj;
};

class NumExpr: public Expr {
public:
    NumExpr(int value) { this->value = value; }
    int evaluate() { return value; }
    int getKind() { return NUM_EXPR; }

    int value;
};

class IdExpr: public Expr {
public:
    IdExpr(string id) { this->id = id; }
    int evaluate() { return vars[id]; }
    int getKind() { return ID_EXPR; }

    string id;
};

class StringExpr: public Expr {
public:
    StringExpr(string str) { this->str = str; }
    int evaluate() { return 0; }
    int getKind() { return STRING_EXPR; }

    string str;
};

enum StatementKind {
    BLOCK_STATEMENT,
    PRINT_STATEMENT,
    ASSIGN_STATEMENT,
    IF_STATEMENT,
    WHILE_STATEMENT,
	FOR_STATEMENT,
	PASS_STATEMENT
};

class Statement {
public:
    virtual void execute() = 0;
    virtual StatementKind getKind() = 0;
};

class BlockStatement: public Statement {
public:
    BlockStatement() {}
    void execute();
    StatementKind getKind() { return BLOCK_STATEMENT; }
	void add(Statement *st) { stList.push_back(st); }

    list<Statement *> stList;
};

class AssignStatement: public Statement {
public:
    AssignStatement(string id, Expr *expr) {
        this->id = id;
        this->expr = expr;
    }
    void execute();
    StatementKind getKind() { return ASSIGN_STATEMENT; }

    string id;
    Expr *expr;
};

class PrintStatement : public Statement
{
public:
  PrintStatement(ExprList espress){ this->espress = espress; }
  void execute();
  StatementKind getKind(){ return PRINT_STATEMENT; }

  ExprList espress;
};

class IfStatement : public Statement
{
public:
  IfStatement(Expr*expr,Statement*ifStmt,Statement*elseStmt)
  {
    this->expr=expr;
    this->ifStmt=ifStmt;
    this->elseStmt=elseStmt;
  }
  
  Expr *expr;
  Statement *ifStmt,*elseStmt;
  void execute();
  StatementKind getKind(){ return IF_STATEMENT; }
};

class ForStatement : public Statement
{
public:
  ForStatement(string id, Expr*from,Expr*to,Statement*block)
  {
    this->id = id;
    this->from=from;
    this->to=to;
    this->block=block;
  }

  string id;
  Expr *from, *to;
  Statement *block;

  void execute();
  StatementKind getKind(){ return FOR_STATEMENT; }
};

class WhileStatement : public Statement
{
public:
  WhileStatement(Expr*expr,Statement*block)
  {
    this->expr=expr;
    this->block=block;
  }

  Expr *expr;
  Statement *block;
  
  void execute();
  StatementKind getKind(){ return WHILE_STATEMENT; }
};

#endif
