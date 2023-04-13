extern int currentDepth;

int isInit(char * name);
int addVarToList(char * name, int init, int type, int decl);
void delVarFromList();
int peek();
int getShift(char * name);
int createTmpVar(int type);
int deleteTmpVar();