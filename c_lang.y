%{
  #include "symbolTable.h"
  #include "createAsm.h"
  #include "branching.h"
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>

  int currentDepth = 0;
  int lineNumber = 1;
  int isRelational = 0;
%}

%code provides {
  void relationTo1Or0(char* op);
  int yylex (void);
  void yyerror (const char *);
}

%union {
  int num;
  char * str;
}

%type <str> math_add_op math_mul_op
%type <str> relation_operator
%type <str> and_or_op
%type <str> function_type
%type <num> if_condition
%type <num> int_list term_list

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

program: 
    function_list { printf("\n----------program parsed correctly----------\n"); }
    | /* empty */ { printf("\n----------empty program----------\n"); }
    ;

function_list: 
    function_declaration
    | function_list function_declaration

statement_list: 
    statement
    | return_statement
    | statement statement_list
    | return_statement statement { fprintf(stderr, "warning: unreachable code from line %d\n", lineNumber); }
    ;

statement: 
    expression_statement
    | if_statement
    | while_statement
    ;

expression_statement: 
    tSEMI /*{ printf("empty expression\n"); }*/
    | expression tSEMI /*{ printf("expression\n"); }*/
    ;

expression: 
    assignment_expression
    | tINT declaration_expression
    ;

block_statement: 
    tLBRACE tRBRACE /*{ printf("empty block\n"); }*/
    | tLBRACE 
      { ++currentDepth;
        /*printf("new current depth: %d\n", currentDepth);*/ } 
    statement_list tRBRACE
      { --currentDepth;
        // printf("new current depth: %d\n", currentDepth);
        int nbDeleted = delVarFromList(); 
        char buf[256]; 
        if (nbDeleted > 0) {
          sprintf(buf, "add sp #%d sp", nbDeleted); 
          writeAsmLine(buf); 
          incrementCounter(INSTR_SIZE);
        } 
        /*printf("block\n");*/ }
    ;

if_statement: 
    tIF if_condition block_statement %prec THEN 
      { newLine();
        // printf("if\n"); 
        addBranching($2); 
        setJumpAddress($2); }
    | tIF if_condition block_statement tELSE
      { addBranching($2);
        writeAsmLine("b .both");
        $<num>4 = getLineCounter();
        addBranching($<num>4);
        incrementCounter(INSTR_SIZE);
        newLine();
        // printf("if/else\n");
        setJumpAddress($2); } 
    block_statement 
      { newLine();
        setJumpAddress($<num>4); }
    ;

if_condition: 
    tLPAR relational_expression tRPAR 
      { writeAsmLine("pop r0");
      incrementCounter(INSTR_SIZE);
      writeAsmLine("add r0 r0 #0");
      incrementCounter(INSTR_SIZE);
      writeAsmLine("beq .else");
      $$ = getLineCounter();
      incrementCounter(INSTR_SIZE); }
    ;

while_statement: 
      { $<num>0 = getLineCounter(); newLine(); } 
    tWHILE tLPAR relational_expression tRPAR 
      { writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("add r0 r0 #0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("beq .else");
        addBranching(getLineCounter());
        $<num>2 = getLineCounter();
        incrementCounter(INSTR_SIZE);
        newLine(); } 
    block_statement 
      { char buf[256]; 
        sprintf(buf, "b 0x%.*X", 2 * ADDRESS_SIZE, $<num>0);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        newLine();
        setJumpAddress($<num>2); }
    ;

return_statement:
    tRETURN tSEMI 
      { writeAsmLine("mov r0 #0");
        incrementCounter(INSTR_SIZE);
        /*printf("returning void\n");*/ }
    | tRETURN math_expression tSEMI 
      { writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        /*printf("returning an expression\n");*/ }
    ;

declaration_expression: 
    tID 
      { writeAsmLine("sub sp sp #1");
        incrementCounter(INSTR_SIZE);
        addVarToList($1, 0, 0); }
    | tID tASSIGN math_expression 
      { deleteTmpVar();
        addVarToList($1, 1, 0);
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("sub sp sp #1");
        incrementCounter(INSTR_SIZE);
        int addr = getShift($1);
        char buf[256];
        sprintf(buf, "str r0 bp%%%d (%s)", addr, $1);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        /*printf("assigning a value\n");*/ }
    | declaration_expression tCOMMA declaration_expression %prec tEMPTY
    ;

assignment_expression:
    tID tASSIGN math_expression
      { deleteTmpVar();
        init($1);
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        int addr = getShift($1);
        char buf[256];
        sprintf(buf, "str r0 bp%%%d (%s)", addr, $1);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        // printf("assigning a value\n");
        free($1); }
    ;

function_declaration:
    function_type tLPAR tVOID 
      { writeAsmLine("push lr");
        createTmpVar(0);
        incrementCounter(INSTR_SIZE);
        /*printf("Tmp var created for lr\n");*/ } 
    tRPAR block_statement 
      { writeAsmLine("pop pc");
        incrementCounter(INSTR_SIZE);
        newLine();
        clearTable();
        /*printf("function with no args\n");*/ }
    | function_type tLPAR int_list 
      { setFunNbArg($1, $3);
      writeAsmLine("push lr");
      createTmpVar(0);
      incrementCounter(INSTR_SIZE);
      /*printf("Tmp var created for lr\n");*/ }
    tRPAR block_statement
      { writeAsmLine("pop pc"); 
        incrementCounter(INSTR_SIZE);
        newLine();
        clearTable();
        /*printf("function\n");*/ }
    ;

function_type:
    tVOID tID
      { addFunToList($2, getLineCounter());
        char buf[256]; sprintf(buf, ".%s", $2);
        writeLabel(buf); $$ = $2; }
    | tINT tID
      { addFunToList($2, getLineCounter());
        char buf[256];
        sprintf(buf, ".%s", $2);
        writeLabel(buf); $$ = $2; }
    ;

int_list:
    tINT tID 
      { $$ = 1;
        // printf("int_list %s\n", $2);
        addVarToList($2, 1, 0); }
    | int_list tCOMMA tINT tID
      { $$ = $1 + 1;
        addVarToList($4, 1, 0); }
    ;

relational_expression: 
    math_expression %prec tEMPTY 
      { if (!isRelational) {
          writeAsmLine("pop r0");
          incrementCounter(INSTR_SIZE);
          writeAsmLine("add r0 r0 #0");
          incrementCounter(INSTR_SIZE);
          relationTo1Or0("beq");
        } }
    | tNOT relational_expression
      { writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("sub r0 #1 r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("push r0");
        incrementCounter(INSTR_SIZE); }
    | math_expression relation_operator math_expression 
      { /*int tmpAddrArg =*/ deleteTmpVar();
        /*int tmpAddrTerm = peek();*/
        writeAsmLine("pop r1");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("sub r0 r0 r1");
        incrementCounter(INSTR_SIZE);
        relationTo1Or0($2); }
    | relational_expression and_or_op relational_expression %prec tEMPTY 
      { writeAsmLine("pop r1");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        char buf[256];
        sprintf(buf, "%s r0 r0 r1", $2);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        relationTo1Or0("beq"); }
    ;

relation_operator: 
    tLT { $$ = "bge"; }
    | tGT { $$ = "ble"; }
    | tLE { $$ = "bgt"; }
    | tGE { $$ = "blt"; }
    | tEQ { $$ = "bne"; }
    | tNE { $$ = "beq"; }
    ;

and_or_op: 
    tAND { $$ = "mul"; }
    | tOR { $$ = "add"; }
    ;

math_expression: 
    math_expression math_add_op math_expression %prec tEMPTY 
      { /*int tmpAddrArg =*/ deleteTmpVar();
        /*int tmpAddrTerm = peek();*/
        writeAsmLine("pop r1");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        char buf[256];
        sprintf(buf, "%s r0 r0 r1", $2);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        writeAsmLine("push r0");
        incrementCounter(INSTR_SIZE); }
    | multiplicative_expression
    ;

multiplicative_expression:
    multiplicative_expression math_mul_op multiplicative_expression %prec tEMPTY
      { /*int tmpAddrArg =*/ deleteTmpVar();
        /*int tmpAddrTerm = peek();*/
        writeAsmLine("pop r1");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        char buf[256];
        sprintf(buf, "%s r0 r0 r1", $2);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        writeAsmLine("push r0");
        incrementCounter(INSTR_SIZE); }
  | term
  ;

math_add_op: 
    tADD { $$ = "add"; }
    | tSUB { $$ = "sub"; }
    ;

math_mul_op:
    tMUL { $$ = "mul"; }
    | tDIV { $$ = "div"; }
    ;

term: 
    tID %prec tEMPTY 
      { if (isInit($1) == 0) {fprintf(stderr, "warning: variable %s hasn't been initialised, line %d\n", $1, lineNumber);}
        /*int addr =*/ createTmpVar(0); 
        // printf("Tmp var created for %s\n", $1);
        char buf[256];
        sprintf(buf, "ldr r0 bp%%%d (%s)", getShift($1), $1);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        writeAsmLine("push r0");
        incrementCounter(INSTR_SIZE);
        free($1);
        isRelational = 0; }
    | tNB 
      { int addr = createTmpVar(0);
        // printf("Tmp var created for '%d'\n", $1);
        char buf[256];
        sprintf(buf, "push #%d (%d)", $1, addr);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        isRelational = 0; }
    | tLPAR math_expression tRPAR { isRelational = 0; }
    | tLPAR relational_expression tRPAR { isRelational = 1; }
    | unary_expression { /*printf("unary\n");*/ isRelational = 0; }
    | function_call { /*printf("f call\n");*/ isRelational = 0; }
    ;

unary_expression: 
    tSUB term 
      { //printf("unary sub\n");
        writeAsmLine("pop r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("sub r0 #0 r0");
        incrementCounter(INSTR_SIZE);
        writeAsmLine("push r0");
        incrementCounter(INSTR_SIZE); }
    | tADD term /*{ printf("unary add\n"); }*/
    ;

function_call: 
    tID tLPAR term_list tRPAR 
      { char buf[256];
        int nbVar = nbVarInTable() - $3;
        sprintf(buf, "mov r0 #%d", nbVar);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        writeAsmLine("sub bp bp r0");
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "mov lr 0x%.*X", 2 * ADDRESS_SIZE, getLineCounter() + 2*INSTR_SIZE);
        writeAsmLine(buf); 
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "b 0x%.*X", 2 * ADDRESS_SIZE, getFunAddr($1, $3));
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "add bp #%d bp", nbVar);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "add sp #%d sp", $3);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        writeAsmLine("push r0");
        incrementCounter(INSTR_SIZE);
        free($1);

        createTmpVar(0);

        for (int i = 0; i < $3; i++) {
            deleteTmpVar();
        } }
    | tID tLPAR tRPAR
      { char buf[256];
        int nbVar = nbVarInTable();
        sprintf(buf, "mov r0 #%d", nbVar);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        writeAsmLine("sub bp bp r0");
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "mov lr 0x%.*X", 2 * ADDRESS_SIZE, getLineCounter() + 2*INSTR_SIZE);
        writeAsmLine(buf); 
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "b 0x%.*X", 2 * ADDRESS_SIZE, getFunAddr($1, 0));
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        sprintf(buf, "add bp #%d bp", nbVar);
        writeAsmLine(buf);
        incrementCounter(INSTR_SIZE);
        free($1); }
    | tPRINT tLPAR term_list tRPAR
      { writeAsmLine("bl .print");
        incrementCounter(INSTR_SIZE);
        /* printf("print!\n"); */ }
    ;

term_list:
    math_expression { $$ = 1; }
    | term_list tCOMMA math_expression { $$ = $1 + 1; }
    ;

%%

void relationTo1Or0(char* op) {
  writeAsmLine("mov r1 #0");
  incrementCounter(INSTR_SIZE);
  char buf[256];
  sprintf(buf, "%s 0x%.*X", op, 2 * ADDRESS_SIZE, getLineCounter() + 2*INSTR_SIZE);
  writeAsmLine(buf);
  incrementCounter(INSTR_SIZE);
  writeAsmLine("mov r1 #1");
  incrementCounter(INSTR_SIZE);
  writeAsmLine("push r1");
  incrementCounter(INSTR_SIZE);
}

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