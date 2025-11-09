CC       := gcc
CFLAGS   ?= -Wall -Wextra -O2
LEX      := flex
YACC     := bison
RM       := rm -f
SHELL    := /bin/sh

TARGET   := pylite

# Caminhos e artefatos do Bison/Flex
BISON_Y  := parser/parser.y
BISON_C  := parser/parser.tab.c
BISON_H  := parser/parser.tab.h

LEX_L    := lexer/lexer.l
LEX_C    := lexer/lex.yy.c

# Script de testes C
TEST_SCRIPT := ./run_c_tests.sh

# Headers gerados ficam em parser/ e podem ser incluídos
CPPFLAGS := -Iparser -Ilexer

run: $(TARGET) ## Compila o binário principal

# Link final (depende dos C gerados por Bison/Flex)
$(TARGET): $(BISON_C) $(LEX_C)
	$(CC) $(CFLAGS) $(CPPFLAGS) -o $@ $(BISON_C) $(LEX_C) -lfl

# Gera parser.tab.c/.h dentro de parser/
$(BISON_C) $(BISON_H): $(BISON_Y)
	$(YACC) -d -o $(BISON_C) --defines=$(BISON_H) $(BISON_Y)

# Gera lex.yy.c dentro de lexer/ (depende do header do parser)
$(LEX_C): $(LEX_L) $(BISON_H)
	$(LEX) -o $(LEX_C) $(LEX_L)

# Alvos de conveniência
parser: $(BISON_C) $(BISON_H) ## Gera apenas o parser (Bison)
lexer:  $(LEX_C)              ## Gera apenas o lexer (Flex)

test: ## Executa os testes C (tests/) via run_c_tests.sh
	@[ -x $(TEST_SCRIPT) ] || chmod +x $(TEST_SCRIPT)
	@env CC="$(CC)" CFLAGS="$(CFLAGS)" $(TEST_SCRIPT)

clean: ## Remove binário e artefatos gerados
	$(RM) $(TARGET) $(BISON_C) $(BISON_H) $(LEX_C)

help: ## Mostra esta ajuda
	@awk 'BEGIN {FS = ":.*##"; printf "Alvos disponíveis:\n"} \
	     /^[a-zA-Z0-9_.-]+:.*##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

.PHONY: run parser lexer test clean help
