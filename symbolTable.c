#include "symbolTable.h"
#include "branching.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* type 0 : integer */
typedef struct {
    char * name;
    int init;
    int type;
    int shift;
    int depth;
} symbol;

typedef struct symbolList symbolList;
struct symbolList {
    symbolList * next;
    symbol * sym;
};

typedef struct {
    char * name;
    int addr;
    int nbArg;
} function;

typedef struct functionList functionList;
struct functionList {
    functionList * next;
    function * fun;
};

symbolList * symList = NULL;
functionList * funList = NULL;

void showSymTable(char* info) {
    symbolList * listAux = symList;
    printf("FORMAT {name, init, type, shift, depth} \t TABLE %s: ", info);
    while(listAux != NULL && listAux->sym != NULL) {
        printf("{%s, %d, %d, %d, %d} ", listAux->sym->name,listAux->sym->init, listAux->sym->type, listAux->sym->shift, listAux->sym->depth);
        listAux = (symbolList*) listAux->next;
    }
    printf("\n");
}

int computeShift() {
    symbolList * listAux = symList;
    int shift = 0;
    while(listAux != NULL) {
        if ((listAux->sym != NULL) && listAux->sym->type == 0) {
            shift++;
        }
        listAux = listAux->next;
    }
    return shift;
}

symbol* symInTable(char * name) {
    if (name == NULL || *name == 0) {
        return NULL;
    }
    symbolList * listAux = symList;
    symbol * sym = NULL;
    while(listAux != NULL) {
        if ((listAux->sym != NULL) && (strcmp(listAux->sym->name, name) == 0)) {
            sym = listAux->sym;
        }
        listAux = listAux->next;
    }
    return sym;
}

int isInit(char* name) {
    int res = 0;
    symbol* sym = symInTable(name);
    if (sym != NULL && sym->init == 1) {
        res = 1; 
    }
    return res;
}

void init(char * name) {
    symbol * sym = symInTable(name);
    if (sym != NULL) {
        sym->init = 1;
    }
    else {
        fprintf(stderr, "Cannot init unexistent variable\n");
        exit(1);
    }
}

int addVarToList(char * name, int init, int type) {
    int shift = -1;
    symbol * inTable = symInTable(name);
    if (inTable != NULL && inTable->depth == currentDepth ) {
        // var already exists
        fprintf(stderr, "error: redefinition of ‘%s’\n", name);
        exit(1);
    }
    else {
        symbolList * listAux = symList;
        
        symbol * symPtr = (symbol*) malloc(sizeof(symbol));
        shift = computeShift();
        symbol newSym = {name, init, type, shift, currentDepth};
        *symPtr = newSym;

        if (symList == NULL) {
            symList = (symbolList*) malloc(sizeof(symbolList));
            symList->next = NULL;
            symList->sym = symPtr;
        }
        else {
            while(listAux->next != NULL) {
                listAux = listAux->next;
            }
            listAux->next = (symbolList*) malloc(sizeof(symbolList));
            listAux->next->next = NULL;
            listAux->next->sym = symPtr;
        }
        showSymTable("after Add");
    }
    return shift;
}

int delVarFromList() {
    symbolList * toDelete = NULL;
    symbolList * listAux = symList;
    symbolList * prev = NULL;
    while(listAux != NULL && listAux->sym != NULL) {
        if ((listAux->sym->depth > currentDepth)) {
            toDelete = listAux;
            if (prev != NULL) {
                prev->next = NULL;
            }
            else {
                symList = NULL;
            }
            break;
        }
        prev = listAux;
        listAux = listAux->next;
    }
    
    // to count the nb of variables (not tmp) that are deleted
    int count = 0;
    while (toDelete != NULL && toDelete->sym != NULL) {
        symbolList* next = toDelete->next;
        if (*toDelete->sym->name != 0) {
            free(toDelete->sym->name);
            count++;
        }
        free(toDelete->sym);
        free(toDelete);
        toDelete = next;
    }
    showSymTable("after Del");
    return count;
}

int nbVarInTable() {
    showSymTable("NB CALL");
    int nbVar = 0;
    symbolList * listAux = symList;
    while(listAux != NULL && listAux->sym != NULL) {
        listAux = (symbolList*) listAux->next;
        nbVar++;
    }
    printf("\n");
    return nbVar;
}

int peek() {
    if (symList == NULL) {
        fprintf(stderr, "Stack is empty\n");
        exit(1);
    }
    symbolList* listAux = symList;
    while(listAux->next != NULL) {
        listAux = listAux->next;
    }
    return listAux->sym->shift;
}

/* if name not found, returns -1. */
int getShift(char * name) {
    symbolList * listAux = symList;
    int shift = -1;
    while (listAux != NULL && listAux->sym != NULL) {
        if (strcmp(listAux->sym->name, name) == 0) {
            shift = listAux->sym->shift;
        }
        listAux = listAux->next;
    }
    return shift;
}

/* create a temporary variable */
int createTmpVar(int type) {
    return addVarToList("", 1, type);
}

/* deletes the last variable of the stack and returns its address */
int deleteTmpVar() {
    if (symList == NULL) {
        fprintf(stderr, "Cannot pop from empty stack\n");
        exit(1);
    }
    int shift;
    symbolList * listAux = symList;
    symbolList * prev = NULL;
    while(listAux->next != NULL) {
        prev = listAux;
        listAux = listAux->next;
    }
    if (prev != NULL) {
        prev->next = NULL;
    }
    else {
        symList = NULL;
    }
    shift = listAux->sym->shift;
    free(listAux->sym);
    free(listAux);
    showSymTable("after pop");
    return shift;
}

void showFunTable(char* info) {
    functionList * listAux = funList;
    printf("FORMAT {name, addr} \t FUN TABLE %s: ", info);
    while(listAux != NULL && listAux->fun != NULL) {
        printf("{%s, 0x%.*X} ", listAux->fun->name, 2 * ADDRESS_SIZE, listAux->fun->addr);
        listAux = (functionList*) listAux->next;
    }
    printf("\n");
}

int funInTable(char * name) {
    functionList * listAux = funList;
    while(listAux != NULL) {
        if ((listAux->fun != NULL) && (strcmp(listAux->fun->name, name) == 0)) {
            return 1;
        }
        listAux = listAux->next;
    }
    return 0;
}

void addFunToList(char * name, int addr, int nbArg) {
    if (funInTable(name)) {
        // function already exists
        fprintf(stderr, "error: redefinition of ‘%s’\n", name);
        exit(1);
    }
    else {
        functionList * listAux = funList;
        
        function * funPtr = (function*) malloc(sizeof(function));
        function newFun = {name, addr, nbArg};
        *funPtr = newFun;

        if (funList == NULL) {
            funList = (functionList*) malloc(sizeof(functionList));
            funList->next = NULL;
            funList->fun = funPtr;
        }
        else {
            while(listAux->next != NULL) {
                listAux = listAux->next;
            }
            listAux->next = (functionList*) malloc(sizeof(functionList));
            listAux->next->next = NULL;
            listAux->next->fun = funPtr;
        }
        showFunTable("after Add");
    }
}

int getFunAddr(char * name, int nbArg) {
    functionList * listAux = funList;
    while (listAux != NULL && listAux->fun != NULL) {
        if (strcmp(listAux->fun->name, name) == 0) {
            if (listAux->fun->nbArg < nbArg) {
                fprintf(stderr, "error: too many arguments to function ‘%s’\n", name);
                exit(1);
            }
            else if (listAux->fun->nbArg > nbArg) {
                fprintf(stderr, "error: too few arguments to function ‘%s’\n", name);
                exit(1);
            }
            return listAux->fun->addr;
        }
        listAux = listAux->next;
    }
    // function doesn't exist
    fprintf(stderr, "error: undefined reference to ‘%s’\n", name);
    exit(1);
}