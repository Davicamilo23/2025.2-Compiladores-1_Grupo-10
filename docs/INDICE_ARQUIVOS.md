# 📂 Índice de Arquivos - Projeto Compilador

## 🏗️ **Arquivos Principais do Compilador**

| Arquivo | Descrição | Status |
|---------|-----------|--------|
| `scanner.l` | Analisador léxico (Flex) - versão simplificada | ✅ Funcional |
| `parser.y` | Analisador sintático (Bison) | ✅ Funcional |
| `Makefile` | Script de compilação | ✅ Funcional |
| `pylite` | Executável compilado | ✅ Gerado |

## 📄 **Arquivos de Backup**

| Arquivo | Descrição | Observações |
|---------|-----------|-------------|
| `scanner_backup.l` | Versão original complexa do scanner | Para Sprint 2 |
| `scanner_simple.l` | Versão simplificada intermediária | Histórico |
| `parser_simple.y` | Versão simplificada intermediária | Histórico |

## 🧪 **Arquivos de Teste**

### **Casos de Teste Python**
| Arquivo | Funcionalidade Testada | Status |
|---------|------------------------|--------|
| `tests/test_simple.c` | Atribuições básicas | ✅ Passa |
| `tests/test_print.c` | Comando print | ✅ Passa |
| `tests/test_basic.c` | Comentários e expressões | ⚠️ Limitado |
| `tests/test_if.c` | Estruturas condicionais | ❌ Não funciona |
| `tests/test_while.c` | Loops | ❌ Não funciona |
| `tests/test_function.c` | Definições de função | ❌ Não funciona |
| `tests/test_error.c` | Casos de erro | ✅ Detecta erros |

### **Scripts de Automação**
| Arquivo | Funcionalidade | Uso |
|---------|----------------|-----|
| `run_c_tests.sh` | Bateria principal de testes | `./run_c_tests.sh` |
| `test_c_errors.sh` | Testes de casos de erro | `./test_c_errors.sh` |
| `teste_manual.sh` | Menu interativo | `./teste_manual.sh` |
| `exemplos_teste.sh` | Exemplos com feedback | `./exemplos_teste.sh` |

## 📚 **Documentação**

| Arquivo | Conteúdo | Público-Alvo |
|---------|----------|--------------|
| `README.md` | Visão geral do projeto | Desenvolvedores |
| `DOCUMENTACAO_SPRINT1.md` | Documentação completa Sprint 1 | Equipe técnica |
| `README_TESTES.md` | Guia específico de testes | Testadores |
| `CHANGELOG.md` | Histórico de mudanças | Todos |
| `INDICE_ARQUIVOS.md` | Este arquivo | Navegação |

## 🌐 **Arquivos Web (MkDocs)**

| Diretório/Arquivo | Descrição |
|-------------------|-----------|
| `mkdocs.yml` | Configuração do MkDocs |
| `docs/` | Documentação web source |
| `site/` | Site gerado (HTML/CSS/JS) |

## 🔧 **Arquivos Gerados (Automático)**

| Arquivo | Gerado por | Quando |
|---------|------------|--------|
| `parser.tab.c` | Bison | `make` |
| `parser.tab.h` | Bison | `make` |
| `lex.yy.c` | Flex | `make` |
| `pylite` | GCC | `make` |

## 📁 **Estrutura de Diretórios**

```
2025.2-Compiladores-1_Grupo-10/
├── 🏗️ Arquivos principais
│   ├── scanner.l
│   ├── parser.y
│   ├── Makefile
│   └── src/main.c
├── 🧪 Testes
│   ├── tests/
│   │   ├── test_simple.c
│   │   ├── test_print.c
│   │   ├── test_basic.c
│   │   ├── test_if.c
│   │   ├── test_while.c
│   │   ├── test_function.c
│   │   └── test_error.c
│   ├── run_c_tests.sh
│   ├── test_c_errors.sh
│   ├── teste_manual.sh
│   └── exemplos_teste.sh
├── 📚 Documentação
│   ├── README.md
│   ├── DOCUMENTACAO_SPRINT1.md
│   ├── README_TESTES.md
│   ├── CHANGELOG.md
│   └── INDICE_ARQUIVOS.md
├── 🌐 Web/Docs
│   ├── docs/
│   ├── site/
│   └── mkdocs.yml
└── 📄 Backup/Histórico
    ├── scanner_backup.l
    ├── scanner_simple.l
    └── parser_simple.y
```

## 🚀 **Fluxo de Trabalho Recomendado**

### **Para Desenvolver**
1. `README.md` - Entender o projeto
2. `DOCUMENTACAO_SPRINT1.md` - Detalhes técnicos
3. `scanner.l` + `parser.y` - Código fonte

### **Para Testar**
1. `README_TESTES.md` - Guia de testes
2. `./run_c_tests.sh` - Executar testes
3. `./teste_manual.sh` - Testes interativos

### **Para Documentar**
1. `CHANGELOG.md` - Registrar mudanças
2. `DOCUMENTACAO_SPRINT1.md` - Atualizar detalhes
3. `mkdocs.yml` - Documentação web

## 🔍 **Localização Rápida**

### **Procurando por...**
- **Como compilar?** → `README.md` ou `Makefile`
- **Como testar?** → `README_TESTES.md`
- **O que mudou?** → `CHANGELOG.md`
- **Detalhes técnicos?** → `DOCUMENTACAO_SPRINT1.md`
- **Problemas conhecidos?** → `CHANGELOG.md` seção "Limitações"
- **Exemplos de uso?** → `tests/` ou `exemplos_teste.sh`

### **Comandos Úteis**
```bash
# Ver todos os arquivos
find . -name "*.md" -o -name "*.sh" -o -name "*.c" -o -name "*.l" -o -name "*.y"

# Ver apenas testes
ls tests/*.c *.sh

# Ver apenas documentação
ls *.md docs/

# Ver arquivos modificados hoje
find . -name "*.c" -o -name "*.sh" -o -name "*.md" | xargs ls -la
```

---

**Última atualização:** 13-14 de Setembro de 2025  
**Sprint:** 1  
**Branch:** Testes
