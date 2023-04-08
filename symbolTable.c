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
    if (name == NULL) {
        return NULL;
    }
    symbolList * listAux = symList;
    symbol * sym = NULL;
    while(listAux != NULL) {
        if ((listAux->sym != NULL) && (listAux->sym->depth == currentDepth) && (strcmp(listAux->sym->name, name) == 0)) {
            sym = listAux->sym;
            break;
        }
        listAux = listAux->next;
    }
    return sym;
}

void addVarToList(char * name, int init, int type) {
    symbol * inTable = NULL;
    if (*name != 0 && (inTable = symInTable(name)) != NULL) {
        // var to update
        inTable->init = init;
    }
    else {
        symbolList * listAux = symList;
        
        symbol * symPtr = malloc(sizeof(symbol));
        symbol newSym = {name, init, type, computeShift(), currentDepth};
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
        free(toDelete->sym->name);
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

/* if name not found, returns -1. currently not used */
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
void createTmpVar(int type) {
    addVarToList("", 1, type);
}

/* deletes the last variable of the stack and returns its address */
int pop() {
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