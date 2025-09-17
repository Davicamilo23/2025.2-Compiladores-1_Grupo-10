# � Compilador C → Python (Flex & Bison)

Este projeto implementa um **compilador que traduz código C para Python** utilizando as ferramentas **Flex** (analisador léxico) e **Bison** (analisador sintático) para a disciplina de Compiladores 1, ministrada pelo professor Dr. Sérgio Antônio no semestre 2025.2, da Faculdade de Ciências e Tecnologia em Engenharia da Universidade de Brasília (FCTE/UnB).

---

## 🎯 Objetivos do Projeto

- Desenvolver um compilador capaz de analisar programas escritos em **C** e traduzi-los para **Python**.
- Explorar conceitos de **Análise Léxica, Sintática e Semântica**.
- Praticar a implementação de compiladores com **C, Flex e Bison**.
- Implementar tradução automática entre linguagens de programação.

---

## ⚙️ Tecnologias Utilizadas

- **C** — linguagem principal de implementação.
- **Flex** — geração do analisador léxico.
- **Bison** — geração do analisador sintático.
- **Makefile** — automação da compilação.

---

## 🚀 Como Executar

1. Clone o repositório:

   ```bash
   git clone https://github.com/Davicamilo23/2025.2-Compiladores-1_Grupo-10.git
   cd 2025.2-Compiladores-1_Grupo-10
   ```

2. Compile o projeto com o `make`:

   ```bash
   make
   ```

3. Execute o compilador com um arquivo C:
   ```bash
   ./c2python exemplo.c
   ```

---

## 🏗️ Arquitetura do Compilador

O compilador segue a arquitetura clássica em fases para tradução C → Python:

1. **Análise Léxica (scanner)**

   - Implementada com **Flex**.
   - Converte o código fonte C em **tokens**.

2. **Análise Sintática (parser)**

   - Implementada com **Bison**.
   - Verifica se a sequência de tokens respeita a gramática da linguagem C.

3. **Análise Semântica**

   - Valida regras semânticas (tipagem, variáveis, escopo).
   - Constrói tabela de símbolos.

4. **Geração de Código Python**
   - Traduz construções C para equivalentes Python.
   - Produz código Python funcional e legível.

---

## 📖 Especificação da Linguagem

### 🔤 Linguagem-Fonte: C (Subconjunto)

Nosso compilador suporta um subconjunto da linguagem C, incluindo:

- **Tipos básicos**: `int`, `float`, `char`
- **Estruturas de controle**: `if/else`, `while`, `for`
- **Funções**: definição e chamada
- **Expressões**: aritméticas, relacionais, lógicas
- **Arrays**: unidimensionais básicos

### 🐍 Linguagem-Alvo: Python

O código C é traduzido para Python idiomático, mantendo:

- **Funcionalidade equivalente**
- **Legibilidade do código**
- **Estruturas Python apropriadas**

Para mais detalhes, consulte nossa [**Especificação Completa da Linguagem**](linguagem-fonte-c.md).

---

## 📚 Exemplos de Tradução

### Exemplo 1: Programa Simples
**Entrada (C):**
```c
#include <stdio.h>

int main() {
    int x = 10;
    printf("Valor: %d\n", x);
    return 0;
}
```

**Saída (Python):**
```python
def main():
    x = 10
    print(f"Valor: {x}")
    return 0

if __name__ == "__main__":
    main()
```

### Exemplo 2: Estrutura Condicional
**Entrada (C):**
```c
int maior(int a, int b) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}
```

**Saída (Python):**
```python
def maior(a, b):
    if a > b:
        return a
    else:
        return b
```

---

## 🧪 Testes e Validação

O projeto inclui uma suíte abrangente de testes:

- **Testes unitários** para cada fase do compilador
- **Casos de teste** com programas C representativos
- **Validação** da equivalência funcional C ↔ Python
- **Testes de erro** para validar tratamento de exceções

---

## 👩‍💻 Equipe

| Nome            | GitHub                                             |
| --------------- | -------------------------------------------------- |
| Ana Elisa Ramos | [@anaelisaramos](https://github.com/anaelisaramos) |
| Arthur Carvalho | [@arthurlleite](https://github.com/arthurlleite)   |
| Davi Camilo     | [@Davicamilo23](https://github.com/Davicamilo23)   |
| Euller Júlio    | [@Potatoyz908](https://github.com/Potatoyz908)     |
| Tiago Antunes   | [@TiagoBalieiro](https://github.com/TiagoBalieiro) |

---

## 📄 Licença

Este projeto é distribuído sob a licença MIT.
