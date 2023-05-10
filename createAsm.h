#ifndef CREATEASM_H
#define CREATEASM_H

void initAsm(const char * filename);
void writeAsmLine(const char * line);
void writeLabel(const char * label);
void newLine();
void closeAsm();

#endif