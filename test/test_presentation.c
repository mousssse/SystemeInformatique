int main(void) {
    int a = 2;
    int b = 10;
    int c = b;
    int d = a;
    int e = b;
    a = d * e;
    e = 0;
    if (b == d) {
        e = 1;
    }
    return e;
    // int warning = 0;
}