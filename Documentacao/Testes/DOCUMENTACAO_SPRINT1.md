# 📖 Documentação de Ajustes e Testes - Sprint 1

## Compilador Python-like (Flex & Bison)

**Data:** 13-14 de Setembro de 2025  
**Branch:** Testes  
**Versão:** Sprint 1  

---

## 🔧 Ajustes Realizados

### 1. **Correção do Scanner (scanner.l)**

#### **Problema Original:**
- Código escrito em C++ com includes incompatíveis com Flex
- Uso de `std::vector` e sintaxe C++
- Erros de compilação com `unrecognised rule`

#### **Ajustes Implementados:**

**Antes:**
```cpp
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <string>

static std::vector<int> indent_stack = {0};
```

**Depois:**
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int indent_stack[100] = {0};
static int indent_stack_size = 1;
```

#### **Estratégia de Simplificação:**
Devido à complexidade da implementação original de indentação, foi criada uma versão simplificada:

```c
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern int yylineno;
%}

%option noyywrap nodefault yylineno

DIGIT         [0-9]
ID_START      [A-Za-z_]
ID_CONT       [A-Za-z0-9_]

%%

[ \t]+        { /* ignore whitespace */ }
\n            { return NEWLINE; }
"#"[^\n]*     { /* ignore comments */ }

// Palavras-chave
"def"         { return DEF; }
"if"          { return IF; }
"elif"        { return ELIF; }
"else"        { return ELSE; }
"while"       { return WHILE; }
"return"      { return RETURN; }
"print"       { return PRINT; }
"and"         { return AND; }
"or"          { return OR; }
"not"         { return NOT; }
"True"        { return TRUE; }
"False"       { return FALSE; }
"None"        { return NONE; }

// Identificadores e literais
{ID_START}{ID_CONT}*  { yylval.s = strdup(yytext); return ID; }
{DIGIT}+              { yylval.s = strdup(yytext); return INT_LIT; }
\"[^\"]*\"            { yylval.s = strdup(yytext); return STRING_LIT; }

// Operadores
"=="          { return EQEQ; }
"!="          { return NE; }
"<="          { return LE; }
">="          { return GE; }
"<"           { return LT; }
">"           { return GT; }
":"           { return COLON; }
","           { return COMMA; }
"("           { return LPAREN; }
")"           { return RPAREN; }
"+"           { return PLUS; }
"-"           { return MINUS; }
"*"           { return STAR; }
"//"          { return SLASHSLASH; }
"%"           { return PERCENT; }
"="           { return ASSIGN; }

"    "        { return INDENT; }

.             { fprintf(stderr, "Unexpected character: %s\n", yytext); }

%%
```

### 2. **Correção do Parser (parser.y)**

#### **Problema Original:**
- Includes C++ incompatíveis
- Definição de tipos semânticos inadequada

#### **Ajustes Implementados:**

**Antes:**
```cpp
#include <cstdio>
#include <cstdlib>
#include <cstring>

%define api.value.type {char*}
```

**Depois:**
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

%union {
    char* s;
}

%token <s> ID INT_LIT STRING_LIT
```

#### **Simplificação da Gramática:**
A gramática foi simplificada para focar nos elementos básicos:

```yacc
program
  : stmts_opt                          { printf("[OK] programa reconhecido\n"); }
  ;

stmts_opt
  : /* vazio */
  | stmts_opt stmt
  ;

stmt
  : simple_stmt NEWLINE
  | compound_stmt
  ;

simple_stmt
  : small_stmt
  ;

small_stmt
  : expr                               
  | ID ASSIGN expr                     { printf("assign %s := expr\n", $1); }
  | PRINT LPAREN arglist_opt RPAREN    { printf("print(...)\n"); }
  | RETURN expr                        { printf("return expr\n"); }
  ;
```

### 3. **Correção do Makefile**

O Makefile original estava correto, sem necessidade de ajustes.

---

## 🧪 Testes Implementados

### 1. **Arquivos de Teste Criados**

#### **`tests/test_simple.py`**
```python
x = 10
y = 20
z = x + y
```
**Objetivo:** Testar atribuições básicas e expressões aritméticas simples.

#### **`tests/test_print.py`**
```python
print("Hello")
result = 5 + 3 * 2
```
**Objetivo:** Testar comando print e precedência de operadores.

#### **`tests/test_basic.py`**
```python
# Teste básico de variáveis e expressões
x = 10
y = 20
z = x + y
print("Hello World")
```
**Objetivo:** Testar comentários, atribuições e print.

#### **`tests/test_if.py`**
```python
# Teste de estrutura condicional if
x = 5
if x > 0:
    print("Positivo")
```
**Objetivo:** Testar estruturas condicionais (limitado pela versão atual).

#### **`tests/test_while.py`**
```python
# Teste de loop while
counter = 0
while counter < 3:
    print(counter)
    counter = counter + 1
```
**Objetivo:** Testar loops (limitado pela versão atual).

#### **`tests/test_function.py`**
```python
# Teste de definição de função
def somar(a, b):
    return a + b

resultado = somar(5, 3)
print(resultado)
```
**Objetivo:** Testar definições de função (limitado pela versão atual).

#### **`tests/test_error.py`**
```python
# Teste com erros sintáticos intencionais
x = 10
if x > 5
    print("Erro: dois pontos ausentes")
```
**Objetivo:** Testar detecção de erros sintáticos.

### 2. **Scripts de Teste Automatizados**

#### **`run_tests.sh`**
```bash
#!/bin/bash

echo "=== TESTE DO COMPILADOR PYLITE ==="
echo ""

echo "1. Teste básico de expressões:"
echo "   Arquivo: test_simple.py"
cat tests/test_simple.py
echo "   Resultado:"
./pylite < tests/test_simple.py
echo ""

echo "2. Teste de print:"
echo "   Arquivo: test_print.py"
cat tests/test_print.py
echo "   Resultado:"
./pylite < tests/test_print.py
echo ""

echo "3. Teste de expressões numéricas:"
echo "   Conteúdo: a = 10 + 5 * 2"
echo "a = 10 + 5 * 2" | ./pylite
echo ""

echo "4. Teste de comparação:"
echo "   Conteúdo: result = x > y"
echo "result = x > y" | ./pylite
echo ""

echo "=== FIM DOS TESTES ==="
```

#### **`test_errors.sh`**
```bash
#!/bin/bash

echo "=== TESTE DE CASOS DE ERRO ==="
echo ""

echo "1. Teste erro de sintaxe - operador inválido:"
echo "   Conteúdo: x = 5 @@ 2"
echo "x = 5 @@ 2" | ./pylite
echo ""

echo "2. Teste erro de sintaxe - parênteses não fechados:"
echo "   Conteúdo: result = (5 + 3"
echo "result = (5 + 3" | ./pylite
echo ""

echo "3. Teste expressão válida com parênteses:"
echo "   Conteúdo: result = (5 + 3) * 2"
echo "result = (5 + 3) * 2" | ./pylite
echo ""

echo "4. Teste tokens válidos:"
echo "   Conteúdo: x = True and False"
echo "x = True and False" | ./pylite
echo ""

echo "=== FIM DOS TESTES DE ERRO ==="
```

#### **`teste_manual.sh`**
Script interativo com menu para testes manuais:
- Teste de expressões aritméticas
- Teste de atribuições
- Teste de operadores lógicos
- Teste de comparações
- Teste de print
- Teste personalizado
- Exemplos válidos

#### **`exemplos_teste.sh`**
Script que executa uma bateria de testes com feedback visual:
- Testa diferentes tipos de construções
- Mostra status de sucesso/erro
- Fornece guia de comandos para teste manual

---

## 📊 Resultados dos Testes

### ✅ **Funcionalidades Testadas e Aprovadas**

| Categoria | Teste | Status | Observações |
|-----------|-------|--------|-------------|
| **Análise Léxica** | Identificadores | ✅ | `x`, `resultado`, `flag` |
| **Análise Léxica** | Números inteiros | ✅ | `10`, `42`, `100` |
| **Análise Léxica** | Strings | ✅ | `"Hello"`, `"World"` |
| **Análise Léxica** | Palavras-chave | ✅ | `True`, `False`, `None`, `and`, `or` |
| **Análise Léxica** | Operadores aritméticos | ✅ | `+`, `-`, `*`, `//`, `%` |
| **Análise Léxica** | Operadores relacionais | ✅ | `==`, `!=`, `<`, `>`, `<=`, `>=` |
| **Análise Léxica** | Operadores lógicos | ✅ | `and`, `or`, `not` |
| **Análise Léxica** | Delimitadores | ✅ | `(`, `)`, `,`, `:` |
| **Análise Sintática** | Atribuições simples | ✅ | `x = 10` |
| **Análise Sintática** | Expressões aritméticas | ✅ | `result = 5 + 3 * 2` |
| **Análise Sintática** | Expressões com parênteses | ✅ | `value = (5 + 3) * 2` |
| **Análise Sintática** | Expressões lógicas | ✅ | `flag = True and False` |
| **Análise Sintática** | Expressões relacionais | ✅ | `check = x >= y` |
| **Análise Sintática** | Comando print | ✅ | `print("texto")` |
| **Tratamento de Erros** | Caracteres inválidos | ✅ | Detecta `@@` como erro |
| **Tratamento de Erros** | Parênteses não fechados | ✅ | Detecta erro sintático |

### ⚠️ **Limitações Identificadas**

| Categoria | Limitação | Motivo | Solução Futura |
|-----------|-----------|--------|----------------|
| **Estruturas de Controle** | `if`/`else` com blocos | Indentação complexa não implementada | Restaurar lexer completo |
| **Estruturas de Controle** | `while` com blocos | Indentação complexa não implementada | Restaurar lexer completo |
| **Definições** | `def` com blocos | Indentação complexa não implementada | Restaurar lexer completo |
| **Comentários** | Processamento em arquivos | Versão simplificada | Melhorar tratamento |

---

## 🎯 Métodos de Teste Manual Disponíveis

### **1. Teste Rápido em Terminal**
```bash
echo "x = 5 + 3" | ./pylite
```

### **2. Teste Interativo**
```bash
./pylite
# Digite código e pressione Ctrl+D
```

### **3. Teste com Arquivo**
```bash
echo "x = 10" > teste.py
./pylite < teste.py
```

### **4. Scripts Automatizados**
```bash
./run_tests.sh          # Bateria de testes
./test_errors.sh        # Testes de erro
./teste_manual.sh       # Menu interativo
./exemplos_teste.sh     # Exemplos com feedback
```

---

## 🚀 Compilação e Execução

### **Comandos de Compilação**
```bash
make clean    # Limpar arquivos gerados
make          # Compilar o projeto
```

### **Estrutura de Arquivos Gerados**
- `pylite` - Executável principal
- `parser.tab.c` / `parser.tab.h` - Código gerado pelo Bison
- `lex.yy.c` - Código gerado pelo Flex

### **Avisos de Compilação (Normais)**
- 14 shift/reduce conflicts (esperado para a gramática atual)
- Funções não utilizadas do Flex (normal)

---

## 📈 Próximos Passos (Sprint 2)

1. **Restaurar suporte completo à indentação**
2. **Implementar estruturas de controle com blocos**
3. **Melhorar tratamento de comentários**
4. **Adicionar mais tipos de dados**
5. **Implementar análise semântica básica**
6. **Adicionar geração de AST**

---

## 📝 Conclusão

A Sprint 1 foi **bem-sucedida** em estabelecer as bases do compilador:

- ✅ **Compilação funcional** do projeto
- ✅ **Análise léxica** completa para tokens básicos
- ✅ **Análise sintática** para expressões e comandos simples
- ✅ **Tratamento de erros** básico implementado
- ✅ **Bateria de testes** abrangente criada
- ✅ **Documentação** completa dos ajustes

O compilador reconhece corretamente a sintaxe básica de Python e está pronto para expansão nas próximas sprints.
