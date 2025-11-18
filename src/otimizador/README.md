# 🚀 Módulo de Otimização - Propagação de Constantes

## 📋 Visão Geral

Este módulo implementa **propagação de constantes** e **constant folding** (dobramento de constantes) sobre a AST do compilador C→Python.

### O que é Propagação de Constantes?

É uma técnica de otimização que:
1. **Identifica** variáveis que recebem valores constantes (literais)
2. **Substitui** usos dessas variáveis pelo valor literal
3. **Avalia** expressões com constantes em tempo de compilação

### Exemplo

**Antes da otimização:**
```c
int x = 5;
int y = x + 3;
int z = y * 2;
```

**Depois da otimização:**
```c
int x = 5;
int y = 8;      // x propagado (5) + folding (5+3=8)
int z = 16;     // y propagado (8) + folding (8*2=16)
```

---

## 🏗️ Arquitetura

```
┌──────────────────────────────────────────────┐
│              AST Original                    │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Passo 1: Propagação de Constantes          │
│  - Registra variáveis com valores literais   │
│  - Substitui identificadores por literais    │
│  - Invalida em reatribuições não-literais    │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Passo 2: Constant Folding                  │
│  - Avalia operações com literais             │
│  - Simplifica expressões aritméticas         │
│  - Trata operadores unários                  │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│  Passo 3: Fixpoint (opcional)               │
│  - Repete passes até convergência            │
│  - Propaga constantes em cadeia              │
└──────────────────────────────────────────────┘
                    │
                    ▼
┌──────────────────────────────────────────────┐
│              AST Otimizada                   │
└──────────────────────────────────────────────┘
```

---

## 📁 Estrutura de Arquivos

```
src/otimizador/
├── otimizador.h        # Interface pública, estruturas de dados
└── otimizador.c        # Implementação dos passes de otimização

tests/otimizacao/
├── test_propagacao_simples.c      # Teste básico de propagação
├── test_constant_folding.c        # Teste de folding aritmético
├── test_multiplas_constantes.c    # Múltiplas variáveis constantes
├── test_invalidacao.c             # Teste de invalidação conservadora
├── test_float.c                   # Operações com ponto flutuante
├── test_unario.c                  # Operadores unários (-, !)
├── test_condicionais.c            # Propagação em if/while
├── test_cadeia.c                  # Propagação em cadeia (fixpoint)
└── run_otimizacao_tests.sh        # Script de execução dos testes
```

---

## 🔧 API Pública

### Gerenciamento da Tabela de Constantes

```c
void inicializarTabelaConstantes(void);
void limparTabelaConstantes(void);
void registrarConstante(const char *nome, Tipo tipo, int valor_int, float valor_float);
InfoConstante* buscarConstante(const char *nome);
void invalidarConstante(const char *nome);
```

### Passes de Otimização

```c
// Passo 1: Propagação de constantes
Ast* passePropagacaoConstantes(Ast *ast);

// Passo 2: Constant folding
Ast* passeConstantFolding(Ast *ast);

// Estatísticas
void imprimirEstatisticasOtimizacao(void);
```

---

## 🎯 Funcionalidades Implementadas

### ✅ Constant Folding

| Operação | Exemplo | Resultado |
|----------|---------|-----------|
| Adição | `2 + 3` | `5` |
| Subtração | `10 - 4` | `6` |
| Multiplicação | `5 * 3` | `15` |
| Divisão | `20 / 4` | `5` |
| Módulo | `17 % 5` | `2` |
| Negação | `-5` | `-5` |
| NOT lógico | `!0` | `1` |
| Comparações | `5 < 10` | `1` |
| Lógicos | `1 && 0` | `0` |

**Suporte a tipos:**
- `int` ✅
- `float` ✅
- Misto (`int` + `float` → `float`) ✅

### ✅ Propagação de Constantes

```c
int x = 5;          // Registra: x → 5
int y = x + 3;      // Substitui x por 5, fold para: y = 8
int z = y * 2;      // Substitui y por 8, fold para: z = 16
```

### ✅ Invalidação Conservadora

```c
int x = 5;          // x é constante (5)
int y = x + 3;      // Usa x (5)
x = y * 2;          // x NÃO é mais constante (depende de y)
int z = x + 1;      // Não propaga x
```

### ✅ Suporte a Estruturas de Controle

- Propagação em condições de `if` e `while`
- Propagação em blocos `{ ... }`
- Propagação em inicializações/condições/incrementos de `for`

---

## 🧪 Como Usar

### 1. Compilar o Compilador

```bash
make clean
make
```

### 2. Executar Testes de Otimização

```bash
chmod +x tests/otimizacao/run_otimizacao_tests.sh
./tests/otimizacao/run_otimizacao_tests.sh
```

### 3. Testar Arquivo Específico

```bash
./compilador < tests/otimizacao/test_propagacao_simples.c
```

Saída esperada:
```
[OPT] Registrada constante: x = 5
[OPT] Propagada constante: x → 5
[OPT] Constant folding: 5 op 3 = 8
...
=== ESTATÍSTICAS DE OTIMIZAÇÃO ===
Constant folding realizados: 3
Propagações de constantes: 2
Total de otimizações: 5
```

---

## 📊 Exemplos de Otimização

### Exemplo 1: Propagação Simples

**Entrada:**
```c
int x = 10;
int y = x * 2;
```

**Log de otimização:**
```
[OPT] Registrada constante: x = 10
[OPT] Propagada constante: x → 10
[OPT] Constant folding: 10 op 2 = 20
```

**AST otimizada:**
```c
int x = 10;
int y = 20;  // otimizado!
```

### Exemplo 2: Constant Folding Complexo

**Entrada:**
```c
int resultado = 2 + 3 * 4;
```

**Log de otimização:**
```
[OPT] Constant folding: 3 op 4 = 12
[OPT] Constant folding: 2 op 12 = 14
```

**AST otimizada:**
```c
int resultado = 14;  // (3*4=12, 2+12=14)
```

### Exemplo 3: Propagação em Cadeia

**Entrada:**
```c
int a = 5;
int b = a;
int c = b + 3;
```

**Passe 1 (Propagação):**
```c
int a = 5;
int b = 5;     // a propagado
int c = b + 3;
```

**Passe 2 (Folding + Propagação):**
```c
int a = 5;
int b = 5;
int c = 8;     // b propagado, folding aplicado
```

---

## ⚙️ Configurações e Limitações

### Abordagem Conservadora

O otimizador usa uma **estratégia conservadora**:
- Qualquer reatribuição com valor não-literal **invalida** a constante
- Não realiza análise de fluxo de controle complexa
- Escopo único (não trata múltiplos níveis de escopo)

### Limitações Conhecidas

1. **Sem análise interprocedural**: Constantes não propagam entre funções
2. **Sem análise de fluxo**: Não detecta caminhos onde variável permanece constante
3. **Invalidação conservadora**: `x = y + 1` invalida `x` mesmo se `y` for constante
4. **Escopo único**: Não distingue variáveis em escopos diferentes
5. **Sem SSA**: Não usa Static Single Assignment para análise precisa

### Melhorias Futuras

Para otimização avançada, considere:
- [ ] Análise de fluxo de dados (reaching definitions)
- [ ] Conversão para SSA (Static Single Assignment)
- [ ] Dead code elimination
- [ ] Análise de ponteiros (alias analysis)
- [ ] Propagação interprocedural
- [ ] Strength reduction (ex: `x * 2` → `x << 1`)

---

## 📈 Métricas

| Métrica | Valor |
|---------|-------|
| **Linhas de código** | ~700 LOC |
| **Operadores suportados** | 13 binários + 4 unários |
| **Tipos suportados** | int, float, char |
| **Testes** | 8 casos de teste |
| **Cobertura** | ~80% dos casos comuns |

---

## 🐛 Debug e Troubleshooting

### Ativar Logs Detalhados

Os logs de otimização são prefixados com `[OPT]`:
```
[OPT] Registrada constante: x = 5
[OPT] Propagada constante: x → 5
[OPT] Constant folding: 5 op 3 = 8
```

### Verificar Estatísticas

Ao final da compilação:
```
=== ESTATÍSTICAS DE OTIMIZAÇÃO ===
Constant folding realizados: 12
Propagações de constantes: 8
Total de otimizações: 20
```

### Problemas Comuns

**Constante não propagada:**
- Verifique se foi invalidada por reatribuição
- Execute múltiplos passes (fixpoint)

**Folding não aplicado:**
- Verifique se ambos operandos são literais
- Divisão por zero é evitada (não faz folding)

---

## 🔗 Integração com Pipeline

O módulo é chamado no `main.c` após análise semântica:

```c
// FASE 3B: Análise semântica
passoChecagemSemantica(ast_raiz);

// FASE 3C: Otimização
inicializarTabelaConstantes();
ast_raiz = passePropagacaoConstantes(ast_raiz);
ast_raiz = passeConstantFolding(ast_raiz);
// Fixpoint (opcional)
ast_raiz = passePropagacaoConstantes(ast_raiz);
ast_raiz = passeConstantFolding(ast_raiz);
imprimirEstatisticasOtimizacao();
limparTabelaConstantes();

// FASE 4: Geração de código Python
gerarCodigoPython(ast_raiz);
```

---

## 📚 Referências

- **Dragon Book**: Compilers: Principles, Techniques, and Tools (Capítulo 9 - Otimização)
- **SSA**: Static Single Assignment Form (Cytron et al., 1991)
- **Constant Propagation**: Wegman & Zadeck, 1991

---

**Autor**: Sistema de Compilação C→Python  
**Data**: Novembro 2025  
**Versão**: 1.0
