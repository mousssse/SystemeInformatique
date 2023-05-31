all: c_lang

c_lang.tab.c c_lang.tab.h:	c_lang.y
	bison -t -v -d c_lang.y

lex.yy.c: c_lang.l c_lang.tab.h
	flex c_lang.l

c_lang: lex.yy.c c_lang.tab.c c_lang.tab.h
	gcc -Wall -g -o c_lang *.c

clean:
	rm c_lang c_lang.tab.c lex.yy.c c_lang.tab.h c_lang.output pythonDict.py

test: all
	./c_lang ./test/output_math.s pythonDict.py < test/test_math.c
	python3 ./crossCompiler.py ./test/output_math.s

	./c_lang ./test/output_if.s pythonDict.py < test/test_if.c
	python3 ./branching.py ./test/output_if.s
	python3 ./crossCompiler.py ./test/output_if.s

	./c_lang ./test/output_while.s pythonDict.py < test/test_while.c
	python3 ./branching.py ./test/output_while.s
	python3 ./crossCompiler.py ./test/output_while.s

	./c_lang ./test/output_function.s pythonDict.py < test/test_function.c
	python3 ./branching.py ./test/output_function.s
	python3 ./crossCompiler.py ./test/output_function.s