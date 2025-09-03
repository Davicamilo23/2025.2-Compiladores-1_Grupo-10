# Makefile simples para Ubuntu/Linux
# - Gera parser (Bison), scanner (Flex) e linka tudo num binário 'pylite'
# - Recompila só o que mudou
# - 'make clean' limpa os artefatos gerados

CC      := gcc
CFLAGS  := -Wall -Wextra -O2
LEX     := flex
YACC    := bison

TARGET  := pylite

all: $(TARGET)

# Regra final: compila o executável a partir dos C gerados pelo Bison/Flex
$(TARGET): parser.tab.c lex.yy.c
	$(CC) $(CFLAGS) -o $@ parser.tab.c lex.yy.c -lfl

# Gera parser.tab.c e parser.tab.h a partir do parser.y (com -d para header)
parser.tab.c parser.tab.h: parser.y
	$(YACC) -d parser.y

# Gera lex.yy.c a partir do scanner.l (depende do header do parser por causa dos tokens)
lex.yy.c: scanner.l parser.tab.h
	$(LEX) scanner.l

# Limpeza
clean:
	rm -f $(TARGET) parser.tab.c parser.tab.h lex.yy.c

.PHONY: all clean
