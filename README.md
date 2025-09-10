# 🐍 Compilador Python (Flex & Bison)

Este projeto implementa um **compilador para a linguagem Python** utilizando as ferramentas **Flex** (analisador léxico) e **Bison** (analisador sintático).

---

## 🎯 Objetivos do Projeto

- Desenvolver um compilador capaz de analisar e interpretar programas escritos em Python (ou um subconjunto definido da linguagem).
- Explorar conceitos de **Análise Léxica, Sintática e Semântica**.
- Praticar a implementação de compiladores com **C, Flex e Bison**.

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
   git clone https://github.com/seu-usuario/seu-repo.git
   cd seu-repo
   ```

2. Compile o projeto com o `make`:

   ```bash
   make
   ```

3. Execute o compilador:
   ```bash
   ./compilares exemplo.py
   ```

---

## 🏗️ Arquitetura do Compilador

O compilador segue a arquitetura clássica em fases:

1. **Análise Léxica (scanner)**

   - Implementada com **Flex**.
   - Converte o código fonte em **tokens**.

2. **Análise Sintática (parser)**

   - Implementada com **Bison**.
   - Verifica se a sequência de tokens respeita a gramática da linguagem.

3. **Análise Semântica**

   - Valida regras semânticas (tipagem, variáveis, etc.).

4. **Geração de Código**
   - Produz código intermediário ou executável final.

---

## 👩‍💻 Equipe

| Nome            | GitHub                                             |
| --------------- | -------------------------------------------------- |
| Ana Elisa Ramos | [@anaelisaramos](https://github.com/anaelisaramos) |
| Arthur Carvalho | [@arthurlleite](https://github.com/arthurlleite)   |
| Davi Camilo     | [@Davicamilo23](https://github.com/Davicamilo23)   |
| Euller Júlio    | [@Potatoyz908](https://github.com/Potatoyz908)     |
| Tiago Antunes   | [@Davicamilo23](https://github.com/TiagoBalieiro)  |

---

## 📄 Licença

Este projeto é distribuído sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais informações.
