CFLAGS=$(shell pkg-config --cflags glib-2.0)
LFLAGS=$(shell pkg-config --libs glib-2.0)

mva: lexico.l gramatica.y
	flex lexico.l
	yacc gramatica.y -d
	gcc $(CFLAGS) -o mva y.tab.c $(LFLAGS) -ly -lm
clean:
	rm -f y.tab.c lex.yy.c y.tab.h mva *.html graph.*
