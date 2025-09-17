# 📖 Especificação da Linguagem-Fonte C

## Compilador C → Python

Este documento define o subconjunto da linguagem C que será a linguagem fonte do nosso compilador, incluindo tokens, estruturas sintáticas, semântica e exemplos de tradução para Python.

---

## 🔤 Especificação de Tokens

### Palavras-Chave (Keywords)
```c
// Tipos de dados
int float char void

// Estruturas de controle
if else while for do switch case default break continue

// Funções e escopo
return

// Inclusões (limitado)
#include

// Entrada/Saída
printf scanf

// Valores especiais
NULL
```

### Operadores

#### Aritméticos
```c
+    // Adição
-    // Subtração
*    // Multiplicação
/    // Divisão
%    // Módulo
++   // Incremento
--   // Decremento
```

#### Relacionais
```c
==   // Igual
!=   // Diferente
<    // Menor
<=   // Menor ou igual
>    // Maior
>=   // Maior ou igual
```

#### Lógicos
```c
&&   // E lógico
||   // OU lógico
!    // NÃO lógico
```

#### Atribuição
```c
=    // Atribuição simples
+=   // Atribuição com adição
-=   // Atribuição com subtração
*=   // Atribuição com multiplicação
/=   // Atribuição com divisão
```

### Delimitadores
```c
{    }    // Chaves (blocos)
(    )    // Parênteses (expressões, funções)
[    ]    // Colchetes (arrays)
;         // Ponto e vírgula (fim de statement)
,         // Vírgula (separador)
```

### Literais

#### Números Inteiros
```c
42       // Decimal
0x2A     // Hexadecimal
052      // Octal
```

#### Números de Ponto Flutuante
```c
3.14     // Float simples
2.5f     // Float com sufixo
1.23e-4  // Notação científica
```

#### Caracteres
```c
'a'      // Caractere simples
'\n'     // Caractere de escape
'\0'     // Caractere nulo
```

#### Strings
```c
"Hello"          // String simples
"Hello\nWorld"   // String com escape
""               // String vazia
```

### Identificadores
```c
// Formato: [a-zA-Z_][a-zA-Z0-9_]*
variavel
_contador
MAX_SIZE
funcao1
array_dados
```

---

## 🏗️ Estruturas Sintáticas Suportadas

### 1. Declarações de Variáveis

#### Declaração Simples
**C:**
```c
int x;
float y;
char c;
```

**Python:**
```python
x = 0        # int inicializado com 0
y = 0.0      # float inicializado com 0.0
c = '\0'     # char inicializado com char nulo
```

#### Declaração com Inicialização
**C:**
```c
int x = 10;
float pi = 3.14;
char letra = 'A';
```

**Python:**
```python
x = 10
pi = 3.14
letra = 'A'
```

#### Arrays
**C:**
```c
int numeros[5];
int valores[3] = {1, 2, 3};
char nome[10];
```

**Python:**
```python
numeros = [0] * 5
valores = [1, 2, 3]
nome = ['\0'] * 10
```

### 2. Expressões

#### Aritméticas
**C:**
```c
resultado = a + b * c;
x = (y + z) / 2;
contador++;
valor *= 3;
```

**Python:**
```python
resultado = a + b * c
x = (y + z) // 2      # Divisão inteira quando apropriado
contador += 1
valor *= 3
```

#### Relacionais e Lógicas
**C:**
```c
if (x > 0 && y < 10) {
    // código
}

bool resultado = (a == b) || (c != d);
```

**Python:**
```python
if x > 0 and y < 10:
    # código
    pass

resultado = (a == b) or (c != d)
```

### 3. Estruturas de Controle

#### If/Else
**C:**
```c
if (condicao) {
    printf("Verdadeiro\n");
} else if (outra_condicao) {
    printf("Outra\n");
} else {
    printf("Falso\n");
}
```

**Python:**
```python
if condicao:
    print("Verdadeiro")
elif outra_condicao:
    print("Outra")
else:
    print("Falso")
```

#### While
**C:**
```c
while (i < 10) {
    printf("%d\n", i);
    i++;
}
```

**Python:**
```python
while i < 10:
    print(i)
    i += 1
```

#### For
**C:**
```c
for (int i = 0; i < 10; i++) {
    printf("%d\n", i);
}
```

**Python:**
```python
for i in range(10):
    print(i)
```

### 4. Funções

#### Definição de Função
**C:**
```c
int somar(int a, int b) {
    return a + b;
}

void imprimir_msg(char* mensagem) {
    printf("%s\n", mensagem);
}
```

**Python:**
```python
def somar(a, b):
    return a + b

def imprimir_msg(mensagem):
    print(mensagem)
```

#### Função Main
**C:**
```c
#include <stdio.h>

int main() {
    printf("Hello World\n");
    return 0;
}
```

**Python:**
```python
def main():
    print("Hello World")
    return 0

if __name__ == "__main__":
    main()
```

### 5. Entrada e Saída

#### Printf
**C:**
```c
printf("Numero: %d\n", x);
printf("Float: %.2f\n", y);
printf("Char: %c\n", c);
printf("String: %s\n", str);
```

**Python:**
```python
print(f"Numero: {x}")
print(f"Float: {y:.2f}")
print(f"Char: {c}")
print(f"String: {str}")
```

#### Scanf (Simplificado)
**C:**
```c
scanf("%d", &x);
scanf("%f", &y);
```

**Python:**
```python
x = int(input())
y = float(input())
```

---

## 📋 Gramática Formal (BNF)

### Programa
```bnf
program         → declaration_list

declaration_list → declaration_list declaration
                 | declaration

declaration     → var_declaration
                | fun_declaration
                | include_declaration

include_declaration → '#include' '<' ID '>'
                    | '#include' STRING_LIT
```

### Declarações de Variáveis
```bnf
var_declaration → type_specifier ID ';'
                | type_specifier ID '=' expression ';'
                | type_specifier ID '[' INT_LIT ']' ';'
                | type_specifier ID '[' INT_LIT ']' '=' '{' expression_list '}' ';'

type_specifier  → 'int' | 'float' | 'char' | 'void'
```

### Declarações de Funções
```bnf
fun_declaration → type_specifier ID '(' params ')' compound_stmt

params          → param_list | 'void' | ε

param_list      → param_list ',' param
                | param

param           → type_specifier ID
                | type_specifier ID '[' ']'
```

### Comandos
```bnf
compound_stmt   → '{' local_declarations statement_list '}'

statement_list  → statement_list statement
                | ε

statement       → expression_stmt
                | compound_stmt
                | selection_stmt
                | iteration_stmt
                | return_stmt

expression_stmt → expression ';'
                | ';'

selection_stmt  → 'if' '(' expression ')' statement
                | 'if' '(' expression ')' statement 'else' statement

iteration_stmt  → 'while' '(' expression ')' statement
                | 'for' '(' expression_stmt expression_stmt expression ')' statement

return_stmt     → 'return' ';'
                | 'return' expression ';'
```

### Expressões
```bnf
expression      → var '=' expression
                | simple_expression

simple_expression → additive_expression relop additive_expression
                  | additive_expression

relop           → '<=' | '<' | '>' | '>=' | '==' | '!='

additive_expression → additive_expression addop term
                    | term

addop           → '+' | '-'

term            → term mulop factor
                | factor

mulop           → '*' | '/' | '%'

factor          → '(' expression ')'
                | var
                | call
                | INT_LIT
                | FLOAT_LIT
                | CHAR_LIT

call            → ID '(' args ')'

args            → arg_list | ε

arg_list        → arg_list ',' expression
                | expression

var             → ID
                | ID '[' expression ']'
```

---

## 🎯 Mapeamento de Tipos C → Python

| Tipo C | Tipo Python | Inicialização | Observações |
|--------|-------------|---------------|-------------|
| `int` | `int` | `0` | Números inteiros |
| `float` | `float` | `0.0` | Números de ponto flutuante |
| `char` | `str` | `'\0'` | Caractere único como string |
| `char[]` | `list[str]` | `['\0'] * size` | Array de caracteres |
| `int[]` | `list[int]` | `[0] * size` | Array de inteiros |
| `void` | `None` | - | Tipo de retorno vazio |

---

## 🚨 Tratamento de Erros

### Erros Léxicos
- Caracteres não reconhecidos
- Literais malformados
- Comentários não fechados

### Erros Sintáticos
- Parênteses não balanceados
- Chaves não balanceadas
- Ponto e vírgula ausente
- Estrutura de função inválida

### Erros Semânticos
- Variável não declarada
- Redeclaração de variável
- Tipo incompatível em atribuição
- Função não declarada
- Número incorreto de argumentos

---

## 📊 Limitações do Subconjunto C

### Não Suportado (Versão Inicial)
- Ponteiros (`*`, `&`)
- Estruturas (`struct`)
- Uniões (`union`)
- Enumerações (`enum`)
- Arquivos múltiplos
- Preprocessador complexo
- Bibliotecas externas (além de stdio.h básico)
- Recursão complexa
- Arrays multidimensionais
- Strings como `char*`

### Funcionalidades Futuras (Sprints Posteriores)
- Ponteiros básicos
- Estruturas simples
- Arrays multidimensionais
- Mais bibliotecas padrão
- Otimizações de código

---

## 🧪 Casos de Teste Representativos

### Teste 1: Programa Básico
**Entrada:**
```c
#include <stdio.h>

int main() {
    int x = 10;
    int y = 20;
    int soma = x + y;
    printf("Soma: %d\n", soma);
    return 0;
}
```

### Teste 2: Função com Parâmetros
**Entrada:**
```c
int multiplicar(int a, int b) {
    return a * b;
}

int main() {
    int resultado = multiplicar(5, 3);
    printf("Resultado: %d\n", resultado);
    return 0;
}
```

### Teste 3: Estruturas de Controle
**Entrada:**
```c
int main() {
    for (int i = 1; i <= 10; i++) {
        if (i % 2 == 0) {
            printf("%d é par\n", i);
        } else {
            printf("%d é ímpar\n", i);
        }
    }
    return 0;
}
```

### Teste 4: Arrays
**Entrada:**
```c
int main() {
    int numeros[5] = {1, 2, 3, 4, 5};
    int soma = 0;
    
    for (int i = 0; i < 5; i++) {
        soma += numeros[i];
    }
    
    printf("Soma: %d\n", soma);
    return 0;
}
```

---

**Versão:** 1.0  
**Data:** 17 de Setembro de 2025  
**Equipe:** Grupo 10 - Compiladores 1
