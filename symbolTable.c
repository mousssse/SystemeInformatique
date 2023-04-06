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

typedef struct {
    struct symbolList * next;
    symbol * sym;
} symbolList;

static symbolList * symList = NULL; 

int computeShift() {
    symbolList * listAux = symList;
    int shift = 0;
    while(listAux != NULL) {
        if (listAux->sym->type == 0) {
            shift++;
        }
        listAux = (symbolList*) listAux->next;
    }
    return shift;
}

int symInTable(char * name) {
    symbolList * listAux = symList;
    int isInTable = 0;
    while(listAux != NULL) {
        if ((listAux->sym->depth == currentDepth) && (strcmp(listAux->sym->name, name) == 0)) {
            isInTable = 1;
            break;
        }
        listAux = (symbolList*) listAux->next;
    }
    return isInTable;
}

void addVarToList(char * name, int init, int type) {
    symbolList * listAux = symList;
    symbol * symPtr;
    if (!symInTable(name)) {
        int shift = computeShift();
        symbol newSym = {name, init, type, shift, currentDepth};
        symPtr = malloc(sizeof(newSym));
    }

    if (symList == NULL) {
        symList = malloc(sizeof(symPtr));
        symList -> next = symPtr;
        symList = (symbol*) symPtr;
    }
    else {
        while(listAux->next != NULL) {
            listAux = (symbolList*) listAux->next;
        }
        listAux->next = (symbol*) symPtr;
    }
}

void delVarFromList() {
    symbolList * listAux = symList;
    symbolList * prev = NULL;
    symbolList * toDelete;
    while(listAux != NULL) {
        if ((listAux->sym->depth > currentDepth)) {
            toDelete = listAux;
            if (prev != NULL) {
                prev->next = NULL;
            }
            break;
        }
        prev = listAux;
        listAux = (symbolList*) listAux->next;
    }

    while (toDelete != NULL) {
        symbolList* next = (symbolList*) toDelete->next;
        free(toDelete);
        toDelete = next;
    }
}

/* if name not found, returns -1 */
int getShift(char * name) {
    symbolList * listAux = symList;
    int shift = -1;
    while (listAux != NULL) {
        if (strcmp(listAux->sym->name, name) == 0) {
            shift = listAux->sym->shift;
        }
        listAux = (symbolList*) listAux->next;
    }
    return shift;
}