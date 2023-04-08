#include <stdio.h>

FILE * file;

void initAsm(const char * filename) {
    file = fopen(filename, "w");
}

void writeAsmLine(const char * line) {
    fprintf(file, "%s", line);
}

void closeAsm() {
    fclose(file);
}