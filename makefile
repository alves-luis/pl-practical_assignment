CFLAGS=$(shell pkg-config --cflags glib-2.0)
LFLAGS=$(shell pkg-config --libs glib-2.0)

filtro: superFiltro.l
	flex superFiltro.l
	gcc $(CFLAGS) -o filtro lex.yy.c $(LFLAGS)

clean:
	rm *.html *.norm
