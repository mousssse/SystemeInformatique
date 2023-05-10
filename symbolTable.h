#ifndef SYMBOLTABLE_H
#define SYMBOLTABLE_H

extern int currentDepth;

int isInit(char * name);
void init(char * name);
int addVarToList(char * name, int init, int type);
int delVarFromList();
int nbVarInTable();
int peek();
int getShift(char * name);
int createTmpVar(int type);
int deleteTmpVar();

int funInTable(char * name);
void addFunToList(char * name, int addr, int nbArg);
int getFunAddr(char * name, int nbArg);

#endif