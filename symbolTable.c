#include "symbolTable.h"
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

static symbolList * symList = NULL;

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

int addVarToList(char * name, int init, int type, int decl) {
    int shift = -1;
    symbol * inTable = symInTable(name);
    if (!decl && inTable != NULL) {
        // var to update
        inTable->init = init;
        shift = inTable->shift;
    }
    else if (decl && inTable != NULL && inTable->depth == currentDepth) {
        shift = inTable->shift;
        printf("re-declaring variable\n");
    }
    else {
        symbolList * listAux = symList;
        
        symbol * symPtr = malloc(sizeof(symbol));
        shift = computeShift();
        symbol newSym = {name, init, type, shift, currentDepth};
        *symPtr = newSym;

        if (symList == NULL) {
            symList = malloc(sizeof(symbolList));
            symList->next = NULL;
            symList->sym = symPtr;
        }
        else {
            while(listAux->next != NULL) {
                listAux = listAux->next;
            }
            listAux->next = malloc(sizeof(symbolList));
            listAux->next->next = NULL;
            listAux->next->sym = symPtr;
        }
        showSymTable("after Add");
    }
    return shift;
}

void delVarFromList() {
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

    while (toDelete != NULL && toDelete->sym != NULL && toDelete->next != NULL) {
        symbolList* next = toDelete->next;
        if (*toDelete->sym->name != 0) {
            free(toDelete->sym->name);
        }
        free(toDelete->sym);
        free(toDelete);
        toDelete = next;
    }
    showSymTable("after Del");
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
    return addVarToList("", 1, type, 0);
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