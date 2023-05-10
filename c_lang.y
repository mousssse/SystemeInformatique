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
          ;

block_statement: tLBRACE tRBRACE { printf("empty block\n"); }
               | tLBRACE { printf("new current depth: %d\n", ++currentDepth); } statement_list tRBRACE { printf("new current depth: %d\n", --currentDepth); int nbDeleted = delVarFromList(); char buf[256]; if (nbDeleted > 0) {sprintf(buf, "add sp, sp, #%d", nbDeleted); writeAsmLine(buf); incrementCounter(4);} printf("block\n"); }
               ;

if_statement: tIF if_condition block_statement %prec THEN { newLine(); printf("if\n"); addBranching($2); setJumpAddress($2); }
            | tIF if_condition block_statement tELSE { addBranching($2); writeAsmLine("b .both"); $<num>4 = getLineCounter(); addBranching($<num>4); incrementCounter(1 + ADDRESS_SIZE); newLine(); printf("if/else\n"); setJumpAddress($2); } block_statement { newLine(); setJumpAddress($<num>4); }
            ;

if_condition: tLPAR relational_expression tRPAR { char* branch = strdup($2); writeAsmLine("pop r0"); incrementCounter(2); char buf[256]; sprintf(buf, "cmp r0, #0"); writeAsmLine(buf); incrementCounter(3); sprintf(buf, "%s .else", branch); writeAsmLine(buf); $$ = getLineCounter(); incrementCounter(1 + ADDRESS_SIZE); free(branch); }

while_statement: { $<num>0 = getLineCounter(); newLine(); } tWHILE tLPAR relational_expression tRPAR { writeAsmLine("pop r0"); incrementCounter(2); writeAsmLine("cmp r0, #0"); incrementCounter(3); char buf[256]; sprintf(buf, "%s .else", $4); writeAsmLine(buf); addBranching(getLineCounter()); $<num>2 = getLineCounter(); incrementCounter(1 + ADDRESS_SIZE); newLine(); } block_statement { char buf[256]; sprintf(buf, "b 0x%.*X", ADDRESS_SIZE, $<num>0); writeAsmLine(buf); newLine(); incrementCounter(1 + ADDRESS_SIZE); setJumpAddress($<num>2);  }
               ;

return_statement: tRETURN tSEMI { writeAsmLine("mov r0, #0"); incrementCounter(3); printf("returning void\n"); }
                | tRETURN math_expression tSEMI { writeAsmLine("pop r0"); incrementCounter(2); printf("returning an expression\n"); }
                ;

declaration_expression: tID { writeAsmLine("sub sp, sp, #1"); incrementCounter(4); addVarToList($1, 0, 0); }
                      | tID tASSIGN math_expression { writeAsmLine("sub sp, sp, #1"); incrementCounter(4); deleteTmpVar(); addVarToList($1, 1, 0); writeAsmLine("pop r0"); incrementCounter(2); int addr = getShift($1); char buf[256]; sprintf(buf, "str r0 bp%%%d (%s)", addr, $1); writeAsmLine(buf); incrementCounter(3); printf("assigning a value\n"); }
                      | declaration_expression tCOMMA declaration_expression %prec tEMPTY
                      ;

/* TODO: Currently, only the last var in id_list can be assigned */
assignment_expression: tID tASSIGN math_expression { deleteTmpVar(); init($1); writeAsmLine("pop r0"); incrementCounter(2); int addr = getShift($1); char buf[256]; sprintf(buf, "str r0, bp%%%d (%s)", addr, $1); writeAsmLine(buf); incrementCounter(3); printf("assigning a value\n"); free($1); }
                     ;

function_declaration: function_type tLPAR tVOID tRPAR block_statement { writeAsmLine("pop pc"); incrementCounter(2); newLine(); printf("function with no args\n"); }
                    | function_type tLPAR int_list tRPAR block_statement { writeAsmLine("pop pc"); incrementCounter(2); newLine(); printf("function\n"); }
                    ;

function_type: tVOID tID { addFunToList($2, getLineCounter(), 0); char buf[256]; sprintf(buf, ".%s", $2); writeLabel(buf); writeAsmLine("push lr"); incrementCounter(2); }
             | tINT tID { addFunToList($2, getLineCounter(), 0); char buf[256]; sprintf(buf, ".%s", $2); writeLabel(buf); writeAsmLine("push lr"); incrementCounter(2); }
             ;

int_list: tINT tID { printf("int_list %s\n", $2); free($2); }
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
                                                                           writeAsmLine("pop r1");
                                                                           incrementCounter(2);
                                                                           writeAsmLine("pop r0");
                                                                           incrementCounter(2);
                                                                           writeAsmLine("sub r0 r0 r1");
                                                                           incrementCounter(4);
                                                                           writeAsmLine("push r0");
                                                                           incrementCounter(2);
                                                                           $$ = $2;
                                                                         }
                     | relational_expression and_or_op relational_expression %prec tEMPTY { writeAsmLine("pop r1");
                                                                                            incrementCounter(2);
                                                                                            writeAsmLine("pop r0");
                                                                                            incrementCounter(2);
                                                                                            char buf[256];
                                                                                            sprintf(buf, "%s r0 r0 r1", $2);
                                                                                            writeAsmLine(buf);
                                                                                            incrementCounter(4);
                                                                                            writeAsmLine("push r0");
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
                                                                              writeAsmLine("pop r1");
                                                                              incrementCounter(2);

                                                                              writeAsmLine("pop r0");
                                                                              incrementCounter(2);

                                                                              char buf[256];
                                                                              sprintf(buf, "%s r0, r0, r1", $2);
                                                                              writeAsmLine(buf);
                                                                              incrementCounter(4);
                                                                              writeAsmLine("push r0");
                                                                              incrementCounter(6);
                                                                            }
              | tLPAR relational_expression tRPAR
              ;

math_operator: tADD { $$ = "add"; }
             | tSUB { $$ = "sub"; }
             | tMUL { $$ = "mul"; }
             | tDIV { $$ = "div"; }
             ;

term: tID %prec tEMPTY { if (isInit($1) == 0) {fprintf(stderr, "warning: variable %s hasn't been initialised\n", $1);} /*int addr =*/ createTmpVar(0); printf("Tmp var created for %s\n", $1); char buf[256]; sprintf(buf, "ldr r0 bp%%%d (%s)", getShift($1), $1); writeAsmLine(buf); incrementCounter(3); writeAsmLine("push r0"); incrementCounter(2); free($1); }
    | tNB { int addr = createTmpVar(0); printf("Tmp var created for '%d'\n", $1); char buf[256]; sprintf(buf, "push #%d (%d)", $1, addr); writeAsmLine(buf); incrementCounter(2); }
    | unary_expression {printf("unary\n");}
    | function_call { printf("f call\n");}
    ;

unary_expression: tSUB term { printf("unary sub\n"); }
                | tADD term { printf("unary add\n"); }
                ;

function_call: tID tLPAR term_list tRPAR { char buf[256];
                                           int nbVar = nbVarInTable();
                                           sprintf(buf, "sub bp, bp, #%d", nbVar);
                                           writeAsmLine(buf);
                                           incrementCounter(4);
                                           sprintf(buf, "mov lr, 0x%.*X", 2 * ADDRESS_SIZE, getLineCounter() + 2 + ADDRESS_SIZE + 1 + ADDRESS_SIZE);
                                           writeAsmLine(buf); 
                                           incrementCounter(2 + ADDRESS_SIZE);
                                           sprintf(buf, "b 0x%.*X", 2 * ADDRESS_SIZE, getFunAddr($1, 0));
                                           writeAsmLine(buf);
                                           incrementCounter(1 + ADDRESS_SIZE);
                                           sprintf(buf, "add bp, bp, #%d", nbVar);
                                           writeAsmLine(buf);
                                           incrementCounter(4);
                                           free($1);
                                         }
             | tID tLPAR tRPAR { char buf[256];
                                 int nbVar = nbVarInTable();
                                 sprintf(buf, "sub bp, bp, #%d", nbVar);
                                 writeAsmLine(buf);
                                 incrementCounter(4);
                                 sprintf(buf, "mov lr, 0x%.*X", 2 * ADDRESS_SIZE, getLineCounter() + 2 + ADDRESS_SIZE + 1 + ADDRESS_SIZE);
                                 writeAsmLine(buf); 
                                 incrementCounter(2 + ADDRESS_SIZE);
                                 sprintf(buf, "b 0x%.*X", 2 * ADDRESS_SIZE, getFunAddr($1, 0));
                                 writeAsmLine(buf);
                                 incrementCounter(1 + ADDRESS_SIZE);
                                 sprintf(buf, "add bp, bp, #%d", nbVar);
                                 writeAsmLine(buf);
                                 incrementCounter(4);
                                 free($1);
                               }
             | tPRINT tLPAR term_list tRPAR { writeAsmLine("bl .print"); incrementCounter(1 + ADDRESS_SIZE); printf("print!\n"); }
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