extern int currentDepth;

int computeShift();
int symInTable(char * name);
void addVarToList(char * name, int init, int type);
void delVarFromList();
int getShift(char * name);
void initLast(char * name);