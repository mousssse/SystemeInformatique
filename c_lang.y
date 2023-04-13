%{
  #include "symbolTable.h"
  #include "createAsm.h"
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
%type <str> relation_operator
%type <str> relational_expression

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

if_statement: tIF tLPAR condition tRPAR statement %prec THEN { printf("if\n"); }
            | tIF tLPAR condition tRPAR statement tELSE { char buf[256]; sprintf(buf, "JMP .both\n.else:\n"); writeAsmLine(buf); printf("if/else\n"); } statement  {char buf[256]; sprintf(buf, ".both:\n"); writeAsmLine(buf); }
            ;

condition: relational_expression { writeAsmLine($1); }

while_statement: tWHILE tLPAR condition tRPAR statement /* TODO: asm loop */
               ;

return_statement: tRETURN tSEMI { printf("returning void\n"); }
                | tRETURN expression tSEMI { char buf[256]; sprintf(buf, "POP {PC}\n"); writeAsmLine(buf); printf("returning an expression\n"); }
                ;

declaration_expression: tID { addVarToList($1, 0, 0, 1); }
                      | tID tASSIGN math_expression { deleteTmpVar(); addVarToList($1, 1, 0, 1); int addr = getShift($1); char buf[256]; sprintf(buf, "POP sp%%%d (%s)\n", addr, $1); writeAsmLine(buf); printf("assigning a value\n"); }
                      | declaration_expression tCOMMA declaration_expression %prec tEMPTY
                      ;

/* TODO: Currently, only the last var in id_list can be assigned */
assignment_expression: tID tASSIGN math_expression { deleteTmpVar(); addVarToList($1, 1, 0, 0); int addr = getShift($1); char buf[256]; sprintf(buf, "POP sp%%%d (%s)\n", addr, $1); writeAsmLine(buf); printf("assigning a value\n"); }
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

relational_expression: math_expression { int tmpAddrArg = peek();
                                         char buf[256];
                                         sprintf(buf, "CMP sp%%%d, #0\nJEQ .else\n", tmpAddrArg);
                                         $$ = buf;
                                       }
                     | tNOT relational_expression { printf("not\n"); }
                     | relational_expression relation_operator relational_expression %prec tEMPTY { int tmpAddrArg = deleteTmpVar();
                                                                                                    int tmpAddrTerm = peek();
                                                                                                    char buf[256];
                                                                                                    sprintf(buf, "SUB sp%%%d sp%%%d sp%%%d\nCMP sp%%%d, #0\n%s .else\n", tmpAddrTerm, tmpAddrTerm, tmpAddrArg, tmpAddrTerm, $2);
                                                                                                    $$ = buf;
                                                                                                  }
                     | relational_expression and_or_op relational_expression %prec tEMPTY
                     ;

relation_operator: tLT { $$ = "JGE"; }
                 | tGT { $$ = "JLE"; }
                 | tLE { $$ = "JGT"; }
                 | tGE { $$ = "JLT"; }
                 | tEQ { $$ = "JNE"; }
                 | tNE { $$ = "JEQ"; }
                 ;

and_or_op: tAND
         | tOR
         ;

math_expression: term
              | math_expression math_operator math_expression  %prec tEMPTY { /*int tmpAddrArg =*/ deleteTmpVar();
                                                                              /*int tmpAddrTerm = peek();*/
                                                                              writeAsmLine("POP R1\nPOP R0\n");
                                                                              char buf[256];
                                                                              sprintf(buf, "%s R0, R0, R1\n", $2);
                                                                              writeAsmLine(buf);
                                                                              writeAsmLine("PUSH R0\n");
                                                                            }
              | tLPAR relational_expression tRPAR
              ;

math_operator: tADD { $$ = "ADD"; printf("add\n"); }
             | tSUB { $$ = "SUB"; printf("sub\n"); }
             | tMUL { $$ = "MUL"; printf("mul\n"); }
             | tDIV { $$ = "DIV"; printf("div\n"); }
             ;

term: tID %prec tEMPTY { if (isInit($1) == 0) {fprintf(stderr, "warning: %s %s %s\n", "variable", $1, "hasn't been initialised");} int addr = createTmpVar(0); printf("Tmp var created for %s\n", $1); char buf[256]; sprintf(buf, "PUSH [sp%%%d (%s)] (%d)\n", getShift($1), $1, addr); writeAsmLine(buf);}
    | tNB { int addr = createTmpVar(0); printf("Tmp var created for '%d'\n", $1); char buf[256]; sprintf(buf, "PUSH #%d (%d)\n", $1, addr); writeAsmLine(buf); }
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

int main(int argc, char** argv) {
  if (argc != 2) {
    yyerror("Wrong number of arguments. Format is: ./c_lang <assembly-file.s>");
  }
  initAsm(argv[1]);
  yyparse();
  closeAsm();
}