all: c_lang

c_lang.tab.c c_lang.tab.h:	c_lang.y
	bison -t -v -d c_lang.y

lex.yy.c: c_lang.l c_lang.tab.h
	flex c_lang.l

c_lang: lex.yy.c c_lang.tab.c c_lang.tab.h
	gcc -Wall -g -o c_lang *.c

clean:
	rm c_lang c_lang.tab.c lex.yy.c c_lang.tab.h c_lang.output

test: all
	#./c_lang ./test/output_math.s < test/test_math.c
	./c_lang ./test/output_if.s < test/test_if.c
	./c_lang ./test/output_while.s < test/test_while.c