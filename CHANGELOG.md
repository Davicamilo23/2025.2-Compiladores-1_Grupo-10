# 📋 Changelog - Compilador Python-like

## [Sprint 1] - 2025-09-13/14

### 🎯 **Objetivo da Sprint**
Estabelecer base funcional do compilador com análise léxica e sintática básicas.

---

## ✅ **Adicionado**

### **Arquivos de Teste**
- `tests/test_simple.py` - Testes de atribuições básicas
- `tests/test_print.py` - Testes de comando print
- `tests/test_basic.py` - Testes com comentários
- `tests/test_if.py` - Estruturas condicionais (preparação)
- `tests/test_while.py` - Loops (preparação)
- `tests/test_function.py` - Definições de função (preparação)
- `tests/test_error.py` - Casos de erro intencionais

### **Scripts de Automação**
- `run_tests.sh` - Bateria principal de testes
- `test_errors.sh` - Testes de casos de erro
- `teste_manual.sh` - Menu interativo para testes
- `exemplos_teste.sh` - Exemplos com feedback visual

### **Documentação**
- `DOCUMENTACAO_SPRINT1.md` - Documentação completa
- `README_TESTES.md` - Guia específico de testes
- `CHANGELOG.md` - Este arquivo

### **Funcionalidades do Compilador**
- Análise léxica de tokens básicos
- Análise sintática de expressões simples
- Tratamento básico de erros
- Suporte a atribuições
- Suporte a comando print
- Reconhecimento de operadores aritméticos
- Reconhecimento de operadores lógicos
- Reconhecimento de operadores relacionais

---

## 🔧 **Modificado**

### **scanner.l**
- **Convertido de C++ para C**
  - Removido: `#include <cstdio>`, `<cstdlib>`, `<cstring>`, `<vector>`, `<string>`
  - Adicionado: `#include <stdio.h>`, `<stdlib.h>`, `<string.h>`
- **Simplificação da estrutura de indentação**
  - Removido: `std::vector<int> indent_stack`
  - Adicionado: `int indent_stack[100]` com `indent_stack_size`
- **Criação de versão simplificada funcional**
  - Foco em tokens básicos
  - Remoção de complexidade de indentação temporariamente

### **parser.y**
- **Convertido de C++ para C**
  - Removido: `#include <cstdio>`, `<cstdlib>`, `<cstring>`
  - Adicionado: `#include <stdio.h>`, `<stdlib.h>`, `<string.h>`
- **Correção da definição de tipos semânticos**
  - Removido: `%define api.value.type {char*}`
  - Adicionado: `%union { char* s; }` com `%token <s>`
- **Simplificação da gramática**
  - Foco em estruturas básicas funcionais
  - Remoção temporária de blocos complexos

---

## 🐛 **Corrigido**

### **Erros de Compilação**
- ✅ Resolvido: "unrecognised rule" no scanner.l
- ✅ Resolvido: Erros de sintaxe C++ em ambiente C
- ✅ Resolvido: "request for member 's' in something not a structure"
- ✅ Resolvido: Conflitos de tipo yylval

### **Problemas de Funcionalidade**
- ✅ Resolvido: Compilador não gerava executável
- ✅ Resolvido: Tokens não eram reconhecidos corretamente
- ✅ Resolvido: Parser rejeitava expressões válidas

---

## ⚠️ **Limitações Conhecidas**

### **Funcionalidades Não Implementadas**
- Blocos indentados (if, while, def com corpo)
- Estruturas de controle complexas
- Análise semântica
- Geração de código
- Tratamento avançado de comentários

### **Decisões Técnicas Temporárias**
- Uso de versão simplificada do lexer
- Gramática reduzida para funcionalidades básicas
- Tratamento de indentação postergado para Sprint 2

---

## 📊 **Estatísticas da Sprint**

### **Arquivos Modificados**
- `scanner.l` - Reescrito (C++ → C)
- `parser.y` - Modificado (C++ → C, união semântica)

### **Arquivos Criados**
- 7 arquivos de teste (.py)
- 4 scripts de automação (.sh)
- 3 arquivos de documentação (.md)

### **Testes Implementados**
- ✅ 18 casos de teste para cada funcionalidade a ser implementada e mais 6 testes de entrada ( para verificar algo que a pessoa tenha escrito errado) todos já em C
- ✅ 4 scripts de automação
- ✅ Testes de erro e validação todos em C
- ✅ Menu interativo para testes manuais

### **Funcionalidades Validadas**
- ✅ Reconhecimento de 13+ tokens diferentes
- ✅ Análise de expressões aritméticas
- ✅ Análise de expressões lógicas
- ✅ Tratamento básico de erros
- ✅ Comando print funcional

---

## 🎯 **Planejamento Sprint 2**

### **Prioridades**
1. **Restaurar suporte à indentação** (scanner_backup.l)
2. **Implementar blocos estruturados** (if, while, def)
3. **Melhorar tratamento de comentários**
4. **Adicionar mais tipos de dados**

### **Metas Técnicas**
- Resolver 14 shift/reduce conflicts
- Implementar AST básica
- Adicionar análise semântica inicial
- Melhorar mensagens de erro

---

## 🏆 **Conquistas da Sprint 1**

- ✅ **Base sólida estabelecida** - Compilador funcional para sintaxe básica
- ✅ **Testes abrangentes** - Cobertura completa das funcionalidades atuais
- ✅ **Documentação completa** - Guias e exemplos detalhados
- ✅ **Automação de testes** - Scripts para validação contínua
- ✅ **Correção de problemas críticos** - Migração C++ → C bem-sucedida

---

**Próxima Sprint:** Implementação de estruturas de controle e blocos indentados  
**Data Prevista:** Sprint 2 - Outubro 2025
    