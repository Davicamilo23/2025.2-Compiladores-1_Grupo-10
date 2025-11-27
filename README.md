# 👨‍🔧 Compilador C → Python (Flex & Bison)

Este projeto implementa um **compilador que traduz código C para Python**, utilizando **Flex** e **Bison** para a disciplina de Compiladores 1, ministrada pelo professor **Dr. Sérgio Antônio** no semestre **2025.2**, da **Faculdade de Ciências e Tecnologia em Engenharia da Universidade de Brasília (FCTE/UnB)**.

---

## 🎯 Objetivos do Projeto

- Desenvolver um compilador capaz de analisar programas escritos em **C** e traduzi-los para **Python**.
- Explorar conceitos de **Análise Léxica, Sintática e Semântica**.
- Praticar a implementação de compiladores com **C, Flex e Bison**.
- Implementar tradução automática entre linguagens de programação.

---

## ⚙️ Tecnologias Utilizadas

- **C** — linguagem principal de implementação.
- **Flex** — gera o analisador léxico.
- **Bison** — gera o analisador sintático.
- **Makefile** — automação da compilação e dos testes.

---

## 📦 Instalação e Dependências

Antes de compilar o projeto, certifique-se de ter instalado:

- **GCC** (compilador C)
- **Flex** (analisador léxico)
- **Bison** (gerador de parser)
- **Make** (automação de build)
- **Python 3** (para executar o código gerado)

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install build-essential flex bison python3 make
```

### macOS (Homebrew)

```bash
brew install flex bison python
```

> Em alguns sistemas, pode ser necessário ajustar o `PATH` para usar as versões do `flex`/`bison` instaladas pelo Homebrew.

### Windows

Em Windows, recomenda-se:

- Instalar o **MSYS2** ou **WSL (Ubuntu)**.
- Dentro do ambiente Linux, usar os mesmos comandos de instalação para Ubuntu/Debian.

---

## 🚀 Como Compilar e Executar

### 1. Compilar o projeto

```bash
make
```

Durante a compilação:

- O **Bison** gera `parser.tab.c` e `parser.tab.h`.
- O **Flex** gera `lex.yy.c`.
- O **GCC** compila tudo e cria o executável `c2python`.

Saída esperada:

```
🖍️ Gerando parser...
🖍️ Gerando lexer...
🔗 Linkando executável...
✅ Compilação concluída! Executável: c2python
```

### 2. Executar o compilador com um arquivo C

```bash
./c2python exemplo.c
```

Se a compilação for bem-sucedida, um arquivo `saida.py` será gerado automaticamente:

```bash
🛠️ Compilação concluída!
Arquivo gerado: saida.py

🔹 Para executar o código Python:
python3 saida.py
```

### 3. Executar com entrada direta (modo interativo)

```bash
make run
```

---

## 📝 Estrutura do Projeto

```
2025.2-Compiladores-1_Grupo-10/
├── lexer/                # Regras léxicas (Flex)
│   └── lexer.l
├── parser/               # Gramática sintática (Bison)
│   └── parser.y
├── src/                  # Implementação principal
│   ├── main.c
│   ├── gerador_python.c
│   └── tabela_simbolos/
│       ├── ast.c
│       ├── tabela.c
│       └── erros.c
├── tests/                # Casos de teste automáticos
│   ├── exemplo.c
│   ├── tipos/
│   └── errors/
├── run_tests.sh          # Script de testes automáticos
├── Makefile              # Automação da build e testes
└── README.md             # Documentação principal
```

---

## 📊 Arquitetura do Compilador

O compilador segue a arquitetura clássica em quatro fases:

1. **Análise Léxica (Flex)** — converte o código C em _tokens_.
2. **Análise Sintática (Bison)** — valida a ordem e a estrutura dos tokens.
3. **Análise Semântica** — verifica tipos, escopo e declarações.
4. **Geração de Código Python** — cria o código equivalente e legível.

---

## 📖 Exemplos de Tradução

### Exemplo 1: Programa simples

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

### Exemplo 2: Estrutura condicional

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

## 🤓 Uso do Makefile

O **Makefile** automatiza todas as etapas do projeto:

| Comando               | Ação                                              |
| --------------------- | ------------------------------------------------- |
| `make`                | Compila todo o projeto                            |
| `make run`            | Executa o compilador interativamente              |
| `make test`           | Executa o teste básico com `exemplo.c`            |
| `make tests`          | Executa toda a suíte automática de testes         |
| `make tests-tipos`    | Executa apenas os testes de tipos                 |
| `make tests-errors`   | Executa apenas os testes de erros                 |
| `make tests-otimizacao` | Executa apenas os testes de otimização          |
| `make tests-lexer`    | Executa apenas os testes de léxico (Flex)         |
| `make tests-ast`      | Executa apenas os testes de AST                   |
| `make tests-exec`     | Executa apenas os testes de execução (C → Python) |
| `make clean`          | Remove arquivos compilados                        |
| `make cleanall`       | Remove todos os arquivos e backups                |
| `make help`           | Mostra os comandos disponíveis                    |

## 🤖 Testes Automatizados

O script **`run_tests.sh`** executa os casos de teste automaticamente, e o Makefile expõe alvos específicos para cada categoria de teste.

### Executar todos os testes principais

```bash
make tests
```

### Testes por categoria

- **Tipos e semântica básica**

  ```bash
  make tests-tipos
  ```

- **Erros sintáticos/semânticos (devem falhar)**

  ```bash
  make tests-errors
  ```

- **Otimização (propagação de constantes, constant folding, etc.)**

  ```bash
  make tests-otimizacao
  ```

- **Léxico (Flex) — tokens, identificadores e literais**

  ```bash
  make tests-lexer
  ```

- **AST — valida a estrutura da Árvore Sintática Abstrata**

  ```bash
  make tests-ast
  ```

- **Execução fim-a-fim (C → Python → saída)**

  ```bash
  make tests-exec
  ```

#### Exemplo de Saída Esperada (testes de erro)

```text
== Rodando testes em tests/errors (modo errors) ==

>> TESTE: tests/errors/div_zero.c
----------------------------------
✅ OK: falhou como esperado -> tests/errors/div_zero.c

----------------------------------
RESUMO FINAL: OK=5 | FAIL=0
----------------------------------
```
## 🛠️ Limpeza

Remover todos os arquivos compilados:

```bash
make clean
```

Remover também arquivos temporários e backups:

```bash
make cleanall
```

---

## 🧠 Dicas Avançadas

Ver conflitos na gramática:

```bash
cd parser && bison -d -Wcounterexamples parser.y
```

Depurar erros de execução:

```bash
gdb ./c2python
run exemplo.c
bt
```

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

## 📜 Licença

Este projeto é distribuído sob a licença **MIT**.

---

**Desenvolvido por:** Grupo 10 • FCTE
