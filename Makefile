# ============================================================
# 🐍 Makefile — Compilador C → Python (Flex & Bison)
# ============================================================
#
# Este Makefile compila o projeto completo:
# - Lexer (lexer/lexer.l)
# - Parser (parser/parser.y)
# - Tabela de símbolos
# - AST
# - Gerador Python
# - Testes automáticos (run_tests.sh)
#
# ============================================================

# Compilador e flags
CC = gcc
CFLAGS = -Wall -Wextra -g -I. -Iparser -Itabela_simbolos
LDFLAGS = -lfl

# Arquivos fonte
LEX_SRC = lexer/lexer.l
YACC_SRC = parser/parser.y
C_SOURCES = src/main.c src/gerador_python.c src/tabela_simbolos/tabela.c src/tabela_simbolos/ast.c

# Arquivos gerados pelo flex/bison
LEX_C = lexer/lex.yy.c
YACC_C = parser/parser.tab.c
YACC_H = parser/parser.tab.h

# Executável final
TARGET = c2python

# ============================================================
# 🧩 Regras principais
# ============================================================

# Regra padrão
all: $(TARGET)

# Gerar o parser a partir do bison (PRIMEIRO)
$(YACC_C) $(YACC_H): $(YACC_SRC)
	@echo "📝 Gerando parser..."
	cd parser && bison -d parser.y

# Gerar o lexer a partir do flex (DEPOIS)
$(LEX_C): $(LEX_SRC) $(YACC_H)
	@echo "📝 Gerando lexer..."
	cd lexer && flex lexer.l

# Compilar o executável final
$(TARGET): $(LEX_C) $(YACC_C)
	@echo "🔗 Linkando executável..."
	$(CC) $(CFLAGS) -o $@ $(LEX_C) $(YACC_C) $(C_SOURCES) $(LDFLAGS)
	@echo "✅ Compilação concluída! Executável: $(TARGET)"

# ============================================================
# 🧹 Limpeza
# ============================================================

clean:
	@echo "🧹 Limpando arquivos gerados..."
	rm -f $(TARGET)
	rm -f $(LEX_C) $(YACC_C) $(YACC_H)
	rm -f *.o src/*.o src/tabela_simbolos/*.o tabela_simbolos/*.o
	rm -f saida.py output.py
	@echo "✅ Limpeza concluída!"

cleanall: clean
	@echo "🧽 Limpando backups..."
	rm -f *~ tabela_simbolos/*~ lexer/*~ parser/*~ src/*~
	@echo "✅ Limpeza completa concluída!"

# ============================================================
# 🧪 Testes
# ============================================================

# Teste básico (exemplo.c)
test: $(TARGET)
	@echo "🧪 Executando teste..."
	@if [ -f tests/exemplo.c ]; then \
		./$(TARGET) tests/exemplo.c; \
	elif [ -f exemplo.c ]; then \
		./$(TARGET) exemplo.c; \
	else \
		echo "⚠️  Arquivo de exemplo não encontrado."; \
	fi

# Rodar toda a suíte automática de testes (run_tests.sh)
tests: $(TARGET)
	@echo "🧪 Rodando suíte completa de testes..."
	@if [ -f ./run_tests.sh ]; then \
		chmod +x ./run_tests.sh; \
		./run_tests.sh; \
	else \
		echo "⚠️  Script 'run_tests.sh' não encontrado na raiz do projeto."; \
	fi

# Rodar apenas testes de tipos
tests-tipos: $(TARGET)
	@echo "🧪 Rodando testes de tipos..."
	@if [ -f ./run_tests.sh ]; then \
		chmod +x ./run_tests.sh; \
		./run_tests.sh tipos; \
	else \
		echo "⚠️  Script 'run_tests.sh' não encontrado."; \
	fi

# Rodar apenas testes de erro
tests-errors: $(TARGET)
	@echo "🧪 Rodando testes de erro..."
	@if [ -f ./run_tests.sh ]; then \
		chmod +x ./run_tests.sh; \
		./run_tests.sh errors; \
	else \
		echo "⚠️  Script 'run_tests.sh' não encontrado."; \
	fi

# ============================================================
# ▶️ Execução manual
# ============================================================

run: $(TARGET)
	@echo "▶️  Executando compilador..."
	./$(TARGET)

# ============================================================
# 📖 Ajuda
# ============================================================

help:
	@echo "======================================"
	@echo "  🐍 MAKEFILE - Compilador C → Python"
	@echo "======================================"
	@echo ""
	@echo "Comandos disponíveis:"
	@echo "  make             - Compila o projeto"
	@echo "  make clean       - Remove arquivos gerados"
	@echo "  make cleanall    - Remove tudo (incluindo backups)"
	@echo "  make test        - Executa um teste simples (exemplo.c)"
	@echo "  make tests       - Executa toda a suíte automática (run_tests.sh)"
	@echo "  make tests-tipos - Executa apenas os testes de tipos"
	@echo "  make tests-errors- Executa apenas os testes de erro"
	@echo "  make run         - Executa o compilador manualmente"
	@echo "  make help        - Mostra esta ajuda"
	@echo ""

# ============================================================
# Alvos não vinculados a arquivos
# ============================================================
.PHONY: all clean cleanall test tests tests-tipos tests-errors run help
