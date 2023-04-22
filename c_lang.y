%{
  #include "symbolTable.h"
  #include "createAsm.h"
  #include "branching.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int currentDepth = 0;
  int lineNumber = 0;
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
%type <str> relation_operator
%type <str> and_or_op
%type <str> relational_expression
%type <num> if_condition

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
              | return_statement
              | statement statement_list
              | return_statement statement { fprintf(stderr, "warning: unreachable code from line %d\n", lineNumber + 1); }
              ;

statement: expression_statement
         | if_statement
         | while_statement
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

if_statement: tIF if_condition block_statement %prec THEN { newLine(); printf("if\n"); addBranching($2); setJumpAddress($2); }
            | tIF if_condition block_statement tELSE { addBranching($2); writeAsmLine("b .both\n"); $<num>4 = getLineCounter(); addBranching($<num>4); incrementCounter(3); newLine(); printf("if/else\n"); setJumpAddress($2); } block_statement { newLine(); setJumpAddress($<num>4); }
            ;

if_condition: tLPAR relational_expression tRPAR { char* branch = strdup($2); writeAsmLine("pop r0\n"); incrementCounter(2); char buf[256]; sprintf(buf, "cmp r0, #0\n"); writeAsmLine(buf); incrementCounter(3); sprintf(buf, "%s .else\n", branch); writeAsmLine(buf); $$ = getLineCounter(); incrementCounter(3); free(branch); }

while_statement: { $<num>0 = getLineCounter(); newLine(); } tWHILE tLPAR relational_expression tRPAR { writeAsmLine("pop r0\n"); incrementCounter(2); writeAsmLine("cmp r0, #0\n"); incrementCounter(3); char buf[256]; sprintf(buf, "%s .else\n", $4); writeAsmLine(buf); addBranching(getLineCounter()); $<num>2 = getLineCounter(); incrementCounter(3); newLine(); } block_statement { char buf[256]; sprintf(buf, "b 0x%04X\n", $<num>0); writeAsmLine(buf); newLine(); incrementCounter(3); setJumpAddress($<num>2);  }
               ;

return_statement: tRETURN tSEMI { printf("returning void\n"); }
                | tRETURN math_expression tSEMI { char buf[256]; sprintf(buf, "pop {pc}\n"); writeAsmLine(buf); incrementCounter(2); printf("returning an expression\n"); }
                | tRETURN function_declaration tSEMI { char buf[256]; sprintf(buf, "pop {pc}\n"); writeAsmLine(buf); incrementCounter(2); printf("returning a function call\n"); }
                ;

declaration_expression: tID { addVarToList($1, 0, 0); }
                      | tID tASSIGN math_expression { deleteTmpVar(); addVarToList($1, 1, 0); int addr = getShift($1); char buf[256]; sprintf(buf, "pop sp%%%d (%s)\n", addr, $1); writeAsmLine(buf); incrementCounter(2); printf("assigning a value\n"); }
                      | declaration_expression tCOMMA declaration_expression %prec tEMPTY
                      ;

/* TODO: Currently, only the last var in id_list can be assigned */
assignment_expression: tID tASSIGN math_expression { deleteTmpVar(); init($1); int addr = getShift($1); char buf[256]; sprintf(buf, "pop sp%%%d (%s)\n", addr, $1); writeAsmLine(buf); incrementCounter(2); printf("assigning a value\n"); free($1); }
                     ;

function_declaration: function_type tLPAR tVOID tRPAR block_statement { printf("function with no args\n"); }
                    | function_type tLPAR int_list tRPAR block_statement { printf("function\n"); }
                    ;

function_type: tVOID tID { free($2); }
             | tINT tID { free($2); }
             ;

int_list: tINT tID { printf("int_list\n"); free($2); }
        | int_list tCOMMA tINT tID  { free($4); }
        ;

relational_expression: math_expression { /*int tmpAddrArg = peek();*/
                                                     char buf[256];
                                                     sprintf(buf, "beq");
                                                     printf("%s\n", buf);
                                                     $$ = buf;
                                                   }
                     | tNOT relational_expression { $$ = "bne"; }
                     | math_expression relation_operator math_expression { /*int tmpAddrArg =*/ deleteTmpVar();
                                                                           /*int tmpAddrTerm = peek();*/
                                                                           writeAsmLine("pop r1\n");
                                                                           incrementCounter(2);
                                                                           writeAsmLine("pop r0\n");
                                                                           incrementCounter(2);
                                                                           writeAsmLine("sub r0 r0 r1\n");
                                                                           incrementCounter(4);
                                                                           writeAsmLine("push r0\n");
                                                                           incrementCounter(2);
                                                                           $$ = $2;
                                                                         }
                     | relational_expression and_or_op relational_expression %prec tEMPTY { writeAsmLine("pop r1\n");
                                                                                            incrementCounter(2);
                                                                                            writeAsmLine("pop r0\n");
                                                                                            incrementCounter(2);
                                                                                            char buf[256];
                                                                                            sprintf(buf, "%s r0 r0 r1\n", $2);
                                                                                            writeAsmLine(buf);
                                                                                            incrementCounter(4);
                                                                                            writeAsmLine("push r0\n");
                                                                                            incrementCounter(2);
                                                                                            $$ = "beq"; 
                                                                                          }
                     ;

relation_operator: tLT { $$ = "bge"; }
                 | tGT { $$ = "ble"; }
                 | tLE { $$ = "bgt"; }
                 | tGE { $$ = "blt"; }
                 | tEQ { $$ = "bne"; }
                 | tNE { $$ = "beq"; }
                 ;

and_or_op: tAND { $$ = "mul"; }
         | tOR { $$ = "add"; }
         ;

//TODO parenthesis/priority in maths
math_expression: term
              | math_expression math_operator math_expression  %prec tEMPTY { /*int tmpAddrArg =*/ deleteTmpVar();
                                                                              /*int tmpAddrTerm = peek();*/
                                                                              writeAsmLine("pop r1\n");
                                                                              incrementCounter(2);

                                                                              writeAsmLine("pop r0\n");
                                                                              incrementCounter(2);

                                                                              char buf[256];
                                                                              sprintf(buf, "%s r0, r0, r1\n", $2);
                                                                              writeAsmLine(buf);
                                                                              incrementCounter(4);
                                                                              writeAsmLine("push r0\n");
                                                                              incrementCounter(6);
                                                                            }
              | tLPAR relational_expression tRPAR
              ;

math_operator: tADD { $$ = "add"; printf("add\n"); }
             | tSUB { $$ = "sub"; printf("sub\n"); }
             | tMUL { $$ = "mul"; printf("mul\n"); }
             | tDIV { $$ = "div"; printf("div\n"); }
             ;

term: tID %prec tEMPTY { if (isInit($1) == 0) {fprintf(stderr, "warning: variable %s hasn't been initialised\n", $1);} int addr = createTmpVar(0); printf("Tmp var created for %s\n", $1); char buf[256]; sprintf(buf, "push [sp%%%d (%s)] (%d)\n", getShift($1), $1, addr); writeAsmLine(buf); incrementCounter(2); free($1); }
    | tNB { int addr = createTmpVar(0); printf("Tmp var created for '%d'\n", $1); char buf[256]; sprintf(buf, "push #%d (%d)\n", $1, addr); writeAsmLine(buf); incrementCounter(2); }
    | unary_expression {printf("unary\n");}
    | function_call {printf("f call\n");}
    ;

unary_expression: tSUB term { printf("unary sub\n"); }
                | tADD term { printf("unary add\n"); }
                ;

function_call: tID tLPAR term_list tRPAR { free($1); }
             | tID tLPAR tRPAR { free($1); }
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

int main(int argc, char** argv) {
  if (argc != 3) {
    yyerror("Wrong number of arguments. Format is: ./c_lang <assembly-file.s> <python-file.py>");
  }
  initAsm(argv[1]);
  yyparse();
  closeAsm();
  addrListToPythonDict(argv[2]);
}