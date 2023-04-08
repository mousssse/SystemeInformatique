extern int currentDepth;

void addVarToList(char * name, int init, int type);
void delVarFromList();
int peek();
void createTmpVar(int type);
int pop();