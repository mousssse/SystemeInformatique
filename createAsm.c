#include <stdio.h>
#include "createAsm.h"
#include "branching.h"

FILE * file;

void initAsm(const char * filename) {
    file = fopen(filename, "w");
}

void writeAsmLine(const char * line) {
    fprintf(file, "0x%.*X: %s", 4, getLineCounter(), line);
}

void newLine() {
    fprintf(file, "\n");
}

void closeAsm() {
    fclose(file);
}