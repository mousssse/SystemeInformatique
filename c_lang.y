%{
  #include "symbolTable.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int currentDepth = 0;
%}

%code provides {
  int yylex (void);
  void yyerror (const char *);
}

%union {
  int num;
  char * str;
}

%type <str> math_operator

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
%left tCOMMA

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
         ;

expression_statement: tSEMI { printf("empty expression\n"); }
                    | expression tSEMI { printf("expression\n"); }
                    ;

expression: assignment_expression
          | tINT declaration_expression
          | relational_expression
          | function_declaration
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

declaration_expression: tID { addVarToList($1, 0, 0); }
                      | assignment_expression
                      | declaration_expression tCOMMA declaration_expression %prec tEMPTY
                      ;

/* TODO: Currently, only the last var in id_list can be assigned */
assignment_expression: tID tASSIGN math_expression { pop(); addVarToList($1, 1, 0); printf("assigning a value\n"); }
                     ;

function_declaration: function_type tLPAR tVOID tRPAR block_statement { printf("function with no args\n"); }
                    | function_type tLPAR int_list tRPAR block_statement { printf("function\n"); }
                    ;

function_type: tVOID tID
             | tINT tID
             ;

int_list: tINT tID { printf("int_list\n"); }
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
              | math_expression math_operator math_expression  %prec tEMPTY { int tmpAddrArg = pop();
                                                                              int tmpAddrTerm = peek();
                                                                              printf("%s @TMP(%d) @TMP(%d) @TMP(%d)\n", $2, tmpAddrTerm, tmpAddrTerm, tmpAddrArg);
                                                                            }
              | tLPAR relational_expression tRPAR
              ;

math_operator: tADD { $$ = "ADD"; printf("add\n"); }
             | tSUB { $$ = "SUB"; printf("sub\n"); }
             | tMUL { $$ = "MUL"; printf("mul\n"); }
             | tDIV { $$ = "DIV"; printf("div\n"); }
             ;

term: tID %prec tEMPTY { createTmpVar(0); printf("Tmp var created for %s\n", $1); }
    | tNB { printf("push #%d\n", $1); createTmpVar(0); printf("Tmp var created for '%d'\n", $1); }
    | unary_expression {printf("unary\n");}
    | function_call {printf("f call\n");}
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