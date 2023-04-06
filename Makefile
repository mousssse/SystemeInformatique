all: c_lang

c_lang.tab.c c_lang.tab.h:	c_lang.y
	bison -t -v -d c_lang.y

lex.yy.c: c_lang.l c_lang.tab.h
	flex c_lang.l

c_lang: lex.yy.c c_lang.tab.c c_lang.tab.h
	gcc -Wall -g -o  c_lang *.c

clean:
	rm c_lang c_lang.tab.c lex.yy.c c_lang.tab.h c_lang.output

test: all
	echo 'void f(void) {int a = 2; a = 2*33+2/4*(5+2*4*(3+2)) + 2; f(3, 4, +5); (1+2)<3;}' | ./c_lang
	@echo ""

	./c_lang < test/test.c