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
int static tempNb = 0;

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

/*
    opType = 0 : COP (id)
    opType = 1 : COP (nb)
    opType = 2 : ADD
    opType = 3 : SUB
    opType = 4 : MUL
    opType = 5 : DIV
*/
void arithmToAsm(char opType, char * name, int value) {
    char* tmpName;
    asprintf(&tmpName, "t%d", ++tempNb);
    if (opType == 0) {
        int addr = getShift(name);
        addVarToList(tmpName, 1, 0);
        int addrTmp = getShift(tmpName);
        printf("COP %d, %d \n", addrTmp, addr);
    }
    else if (opType == 1) {
        addVarToList(tmpName, 1, 0);
        int addrTmp = getShift(tmpName);
        printf("COP %d, %d \n", addrTmp, value);
    }
    else if (opType == 2) {
        int t1 = freeTmp();
        int t2 = getLastAddr();
        printf("ADD %d, %d, %d\n", t1, t1, t2);
    }
    else if (opType == 3) {
        int t1 = freeTmp();
        int t2 = getLastAddr();
        printf("SUB %d, %d, %d\n", t1, t1, t2);
    }
    else if (opType == 4) {
        int t1 = freeTmp();
        int t2 = getLastAddr();
        printf("MUL %d, %d, %d\n", t1, t1, t2);
    }
    else if (opType == 5) {
        int t1 = freeTmp();
        int t2 = getLastAddr();
        printf("DIV %d, %d, %d\n", t1, t1, t2);
    }
}
