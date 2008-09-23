
YACC=bison
LEX=flex
CC=gcc

OUTPUT=parser
YACC_FLAGS=-d
LEX_FLAGS=

all: token.c fdl_file.c lex.yy.c fdl.tab.c
	${CC} token.c fdl_file.c lex.yy.c fdl.tab.c -o ${OUTPUT}

lex.yy.c: 
	${LEX} ${LEX_FLAGS} fdl.l
	
fdl.tab.c:
	${YACC} ${YACC_FLAGS} fdl.y

clean:
	rm -rf lex.yy.c fdl.tab.c fdl.tab.h parser
