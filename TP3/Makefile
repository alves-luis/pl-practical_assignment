mva: lexico.l gramatica.y
	flex lexico.l
	yacc gramatica.y -d
	gcc -o mva y.tab.c -ly -lm
clean:
	rm -f y.tab.c lex.yy.c y.tab.h mva
