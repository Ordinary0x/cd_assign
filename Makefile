TARGET = bcs24

all: $(TARGET)

$(TARGET): lex.yy.c parser_1.tab.c
	gcc -Wall -std=gnu99 lex.yy.c parser_1.tab.c -o $(TARGET)

lex.yy.c: lexer_1.l parser_1.tab.h
	flex lexer_1.l

parser.tab.c parser_1.tab.h: parser_1.y
	bison -d parser_1.y

clean:
	rm -f $(TARGET) lex.yy.c parser_1.tab.c parser_1.tab.h