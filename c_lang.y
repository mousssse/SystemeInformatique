%{
  #include "symbolTable.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int currentDepth = 0;
  char * lastID;
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
}

%union {
  int num;
  char *str;
}

%token <str> tID
%token <num> tNB
%token tIF tELSE tWHILE tPRINT tRETURN tINT tVOID
%token tADD tSUB tMUL tDIV tLT tGT tNE tEQ tGE tLE tASSIGN tAND tOR tNOT
%token tLBRACE tRBRACE tLPAR tRPAR tSEMI tCOMMA

%left tEMPTY 

%left tOR tAND
%nonassoc tEQ tNE
%nonassoc tLT tGT tLE tGE
%nonassoc tNOT

%right THEN tELSE

%right tLPAR
%left tRPAR
%left tADD tSUB tMUL tDIV

%%

program: {currentDepth = 0;} function_list { printf("\n----------program parsed correctly----------\n"); }
       | /* empty */ { printf("\n----------empty program----------\n"); }
       ;

function_list: function_declaration
             | function_list function_declaration

statement_list: statement
              | statement_list statement
              ;

statement: expression_statement
         | block_statement
         | if_statement
         | while_statement
         | return_statement
         | declaration_statement
         ;

expression_statement: tSEMI { printf("empty expression\n"); }
                    | expression tSEMI { printf("expression\n"); }
                    ;

expression: assignment_expression
          | relational_expression
          ;

block_statement: tLBRACE tRBRACE { printf("empty block\n"); }
               | tLBRACE { printf("new current depth: %d\n", ++currentDepth); } statement_list tRBRACE { printf("new current depth: %d\n", --currentDepth); delVarFromList(); printf("block\n"); }
               ;

if_statement: tIF tLPAR relational_expression tRPAR statement %prec THEN { printf("if\n"); }
            | tIF tLPAR relational_expression tRPAR statement tELSE statement { printf("if/else\n"); }
            ;

while_statement: tWHILE tLPAR relational_expression tRPAR statement
               ;

return_statement: tRETURN tSEMI { printf("returning void\n"); }
                | tRETURN expression tSEMI { printf("returning an expression\n"); }
                ;

declaration_statement: tINT id_list tSEMI {printf("Adding variables\n");}
                     | tINT assignment_expression tSEMI {printf("Assigning variables\n");}
                     | function_declaration {printf("function declaration\n");}
                     ;

/* TODO: Currently, only the last var in id_list can be assigned */
assignment_expression: id_list tASSIGN math_expression { initLast(lastID); printf("assigning a value\n"); }
                     ;

id_list: tID {addVarToList($1,0,0); lastID = $1;}
       | tID tCOMMA id_list {addVarToList($1,0,0);}
       ;

function_declaration: function_type tLPAR tVOID tRPAR block_statement { printf("function with no args\n"); }
                    | function_type tLPAR int_list tRPAR block_statement { printf("function\n"); }
                    ;

function_type: tVOID tID
             | tINT tID
             ;

int_list: tINT tID {printf("int_list\n");}
        | int_list tCOMMA tINT tID
        ;

relational_expression: math_expression
                     | tNOT relational_expression { printf("not\n"); }
                     | relational_expression relation_operator relational_expression %prec tEMPTY { printf("relation\n"); }
                     ;

relation_operator: tLT { printf("lower\n"); }
                 | tGT { printf("greater\n"); }
                 | tLE { printf("lower/equal\n"); }
                 | tGE { printf("greater/equal\n"); }
                 | tEQ { printf("equal\n"); }
                 | tNE { printf("different\n"); }
                 | tAND { printf("and\n"); }
                 | tOR { printf("or\n"); }
                 ;

math_expression: term
              | math_expression math_operator math_expression  %prec tEMPTY
              | tLPAR relational_expression tRPAR
              ;

math_operator: tADD { printf("add\n"); }
             | tSUB { printf("sub\n"); }
             | tMUL { printf("mul\n"); }
             | tDIV { printf("div\n"); }
             ;

term: tID %prec tEMPTY { printf("id: '%s'\n", $1); }
    | tNB { printf("number: '%d'\n", $1); }
    | unary_expression
    | function_call
    ;

unary_expression: tSUB term { printf("unary sub\n"); }
                | tADD term { printf("unary add\n"); }
                ;

function_call: tID tLPAR term_list tRPAR
             | tID tLPAR tRPAR
             | tPRINT tLPAR term_list tRPAR { printf("print!\n"); }
             ;

term_list: math_expression
         | term_list tCOMMA math_expression
         ;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "error: %s\n", msg);
  exit(1);
}