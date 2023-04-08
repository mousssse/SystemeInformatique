extern int currentDepth;

int addVarToList(char * name, int init, int type);
void delVarFromList();
int peek();
int getShift(char * name);
int createTmpVar(int type);
int deleteTmpVar();