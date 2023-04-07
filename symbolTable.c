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

void showSymTable(char* info){
    symbolList * listAux = symList;
    printf("FORMAT [name, init, type, shift, depth] \t TABLE %s: ", info);
    while(listAux != NULL && listAux->sym != NULL) {
        printf("[%s, %d, %d, %d, %d] ", listAux->sym->name,listAux->sym->init, listAux->sym->type, listAux->sym->shift, listAux->sym->depth);
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

int symInTable(char * name) {
    if (name == NULL) {
        return 0;
    }
    symbolList * listAux = symList;
    int isInTable = 0;
    while(listAux != NULL) {
        if ((listAux->sym != NULL) && (listAux->sym->depth == currentDepth) && (strcmp(listAux->sym->name, name) == 0)) {
            isInTable = 1;
            break;
        }
        listAux = listAux->next;
    }
    return isInTable;
}

void addVarToList(char * name, int init, int type) {
    symbolList * listAux = symList;
    symbol * symPtr = NULL;
    if (!symInTable(name)) {
        int shift = computeShift();
        symbol newSym = {name, init, type, shift, currentDepth};
        symPtr = malloc(sizeof(symbol));
        *symPtr = newSym;
    }

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

void delVarFromList() {
    symbolList * toDelete = NULL;
    
    if (currentDepth == 0) {
        toDelete = symList;
        symList = NULL;
    }
    else {
        symbolList * listAux = symList;
        symbolList * prev = NULL;
        while(listAux != NULL && listAux->sym != NULL) {
            if ((listAux->sym->depth > currentDepth)) {
                toDelete = listAux;
                if (prev != NULL) {
                    prev->next = NULL;
                }
                break;
            }
            prev = listAux;
            listAux = listAux->next;
        }
    }

    while (toDelete != NULL && toDelete->next != NULL) {
        symbolList* next = toDelete->next;
        free(toDelete);
        toDelete = next;
    }
    showSymTable("after Del");
}

/* if name not found, returns -1 */
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

void initLast(char * name) {
    symbolList * listAux = symList;
    symbol * last = listAux->sym;
    int found = 0;
    while (listAux != NULL && listAux->sym != NULL) {
        if (strcmp(listAux->sym->name, name) == 0) {
            last = listAux->sym;
            found = 1;
        }
        listAux = listAux->next;
    }
    if (found) {
        last->init = 1;
    }
    else {
        fprintf(stderr, "Declaration missing for variable: %s\n", name);
        exit(1);
    }
    showSymTable("after init");
}