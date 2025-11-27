# 🧭 Guia de Instalação, Compilação e Uso

Este guia descreve, passo a passo, como preparar o ambiente, compilar e usar o **compilador C → Python** desenvolvido pelo Grupo 10.

---

## 📦 Pré-requisitos

Antes de tudo, instale as seguintes ferramentas:

- **GCC** — compilador C
- **Flex** — gerador do analisador léxico
- **Bison** — gerador do analisador sintático (parser)
- **Make** — automação do processo de build
- **Python 3** — para executar o código Python gerado (`saida.py`)

### Linux (Ubuntu/Debian)

```bash
sudo apt update
sudo apt install build-essential flex bison python3 make
```

### macOS (Homebrew)

```bash
brew install flex bison python
```

> Em alguns casos, será necessário ajustar o `PATH` para usar as versões do `flex`/`bison` instaladas pelo Homebrew.

### Windows

No Windows, recomenda-se:

1. Usar **WSL (Ubuntu)** ou **MSYS2**.
2. Dentro do ambiente Linux, seguir os mesmos passos de instalação usados para Ubuntu/Debian.

---

## 📥 Clonando o Repositório

```bash
git clone https://github.com/Davicamilo23/2025.2-Compiladores-1_Grupo-10.git
cd 2025.2-Compiladores-1_Grupo-10
```

---

## 🏗️ Compilando o Compilador

Para gerar o executável `c2python`:

```bash
make
```

Durante essa etapa:

- O **Bison** lê `parser/parser.y` e gera:
  - `parser/parser.tab.c`
  - `parser/parser.tab.h`
- O **Flex** lê `lexer/lexer.l` e gera:
  - `lexer/lex.yy.c`
- O **GCC** compila todos os arquivos C em `src/`, `lexer/` e `parser/` e:
  - Linka tudo em um único binário: **`c2python`**

Saída típica:

```text
📝 Gerando parser...
📝 Gerando lexer...
🔗 Linkando executável...
✅ Compilação concluída! Executável: c2python
```

Se aparecer erro como `bison: not found` ou `flex: not found`, significa que os pré-requisitos ainda não foram instalados corretamente.

---

## ▶️ Usando o Compilador

### 1. Traduzir um arquivo C para Python

```bash
./c2python caminho/para/arquivo.c
```

Isso irá:

1. Ler o código C.
2. Realizar:
   - análise léxica,
   - análise sintática,
   - construção da **AST**,
   - análise semântica,
   - otimizações simples,
3. Gerar um arquivo **`saida.py`** na raiz do projeto.

Para executar o Python gerado:

```bash
python3 saida.py
```

### 2. Executar um exemplo rápido

O repositório já traz um exemplo básico:

```bash
make test
```

Esse comando usa `tests/exemplo.c` (ou `exemplo.c` na raiz) para demonstrar o fluxo completo de compilação e geração de `saida.py`.

### 3. Modo interativo (entrada via stdin)

```bash
make run
```

Você poderá digitar código C diretamente no terminal e, ao finalizar (Ctrl+D no Linux/macOS), o compilador irá processar a entrada.

---

## 🧪 Executando os Testes

O projeto possui uma suíte de testes automáticos que exercita:

- Léxico
- Sintático + AST
- Semântico (tipos)
- Erros
- Otimizações
- Execução fim-a-fim (C → Python → saída)

Principais comandos:

```bash
make tests          # suíte principal
make tests-tipos    # apenas testes de tipos/semântica
make tests-errors   # apenas programas que DEVEM falhar
make tests-otimizacao  # somente otimizações
make tests-lexer    # foco no léxico (tokens)
make tests-ast      # valida a estrutura da AST
make tests-exec     # verifica se o Python gerado executa corretamente
```

> Dica: esses comandos assumem que o executável `c2python` já foi gerado com `make`.

---

## 🧠 Como o Processo de Compilação Funciona

Em alto nível, o fluxo do compilador é:

1. **Análise Léxica (Flex)**  
   Converte o texto fonte em **tokens** (identificadores, números, palavras-chave, operadores, etc.).

2. **Análise Sintática (Bison)**  
   Usa a gramática definida em `parser/parser.y` para construir uma **Árvore Sintática Abstrata (AST)**.

3. **Análise Semântica**  
   Percorre a AST e a tabela de símbolos para verificar:
   - tipos compatíveis,
   - variáveis declaradas/uso correto,
   - retornos de função, etc.

4. **Otimizações**  
   Aplica passes simples, como:
   - propagação de constantes,
   - constant folding,
   - simplificação de expressões.

5. **Geração de Código Python**  
   A AST final é percorrida e traduzida para um programa Python estruturado, que é salvo em `saida.py`.

---

## ✅ Verificando se Está Tudo Funcionando

1. Compile o projeto:

   ```bash
   make
   ```

2. Rode um teste básico:

   ```bash
   make test
   ```

3. Verifique se o arquivo `saida.py` foi gerado e execute:

   ```bash
   python3 saida.py
   ```

4. Opcionalmente, rode toda a suíte de testes:

   ```bash
   make tests
   ```

Se esses passos funcionarem sem erros, o ambiente está corretamente configurado e o compilador está operacional.
