#ifndef BRANCHING_H
#define BRANCHING_H
#define ADDRESS_SIZE 2

void addBranching(int branchAddress);
void setJumpAddress(int branchAddress);
void incrementCounter(int increment);
int getLineCounter();
void addrListToPythonDict(const char * filename);

#endif