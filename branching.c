#include "branching.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
    int branchAddress;
    int jumpAddress;
} addresses;

typedef struct addressList addressList;
struct addressList {
    addressList * next;
    addresses * addr;
};

int lineCounter = 0x00;
static addressList * addrList = NULL;

void addBranching(int branchAddress) {
    addressList * listAux = addrList;
        
    addresses * addr = (addresses*) malloc(sizeof(addresses));
    addresses newAddr = {branchAddress, 0};
    *addr = newAddr;

    if (addrList == NULL) {
        addrList = (addressList*) malloc(sizeof(addressList));
        addrList->next = NULL;
        addrList->addr = addr;
    }
    else {
        while(listAux->next != NULL) {
            listAux = listAux->next;
        }
        listAux->next = (addressList*) malloc(sizeof(addressList));
        listAux->next->next = NULL;
        listAux->next->addr = addr;
    }
}

void setJumpAddress(int branchAddress) {
    addressList * listAux = addrList;
    while(listAux != NULL) {
        if ((listAux->addr != NULL) && listAux->addr->branchAddress == branchAddress) {
            listAux->addr->jumpAddress = lineCounter;
            break;
        }
        listAux = listAux->next;
    }
}

void incrementCounter(int increment) {
    lineCounter += increment;
}

int getLineCounter() {
    return lineCounter;
}

void showAddrList() {
    addressList * listAux = addrList;
    printf("Addresses list:\n");
    while(listAux != NULL && listAux->addr != NULL) {
        printf("\t0x%04X -> 0x%04X\n", listAux->addr->branchAddress, listAux->addr->jumpAddress);
        listAux = (addressList*) listAux->next;
    }
    printf("\n");
}