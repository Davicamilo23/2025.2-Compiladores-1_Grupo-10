# 🧪 Guia de Testes — Compilador (suíte portada para **C**)

> Esta versão migra os testes que estavam em Python para **C**, mantendo a mesma intenção de verificação (incluindo casos de **erro**). Cada teste é um programa com `main()` e validação via `printf`.

---

## Como Executar os Testes

### 🚀 Início Rápido

1. **(Opcional) Compilar o projeto principal**
   ```bash
   make clean && make
   ```

2. **Executar a bateria de testes em C**
   ```bash
   chmod +x run_c_tests.sh
   ./run_c_tests.sh
   ```

3. **Verificar os casos de erro (espera-se falha na compilação)**
   ```bash
   chmod +x test_c_errors.sh
   ./test_c_errors.sh
   ```

---

## 📁 Estrutura de Testes

```
tests_c/
├── test_basic.c
├── test_function.c
├── test_if.c
├── test_if_else.c
├── test_if_elif_else.c
├── test_if_flat.c
├── test_if_simple.c
├── test_nested_blocks.c
├── test_print.c
├── test_ptr_arith.c
├── test_ptr_chain.c
├── test_ptr_decl_assign.c
├── test_ptr_if_while.c
├── test_scope.c
├── test_simple.c
├── test_while.c
└── errors/
    ├── div_zero.c
    ├── dois_pontos_ausente.c
    ├── erro_de_ortografia.c
    ├── mal_identacao.c
    ├── tipo_incorreto.c
    └── variavel_desconhecida.c

Scripts:
├── run_c_tests.sh      # compila e executa os testes "válidos"
└── test_c_errors.sh    # confirma que os casos em errors/ falham na compilação
```

---

## ✅ Casos de Teste que Funcionam

### **Atribuições Simples**
```c
int x = 10;
int y = 20;
int z = x + y;
```

### **Expressões Aritméticas**
```c
int resultado = 5 + 3 * 2;
int valor = (10 + 5) * 2;
int resto = 42 % 5;
```

### **Expressões Lógicas / Comparações**
```c
int x = 5, y = 10;
int maior  = x > y;     // 0
int igual  = x == y;    // 0
int menorE = x <= y;    // 1
```

### **Saída com `printf`**
```c
printf("Hello World\n");
printf("z=%d\n", z);
```

### **Controle de Fluxo**
```c
if (x > 0) printf("Positivo\n");

int counter = 0;
while (counter < 3) {
    printf("%d\n", counter);
    counter++;
}
```

### **Funções**
```c
static int somar(int a, int b) { return a + b; }
printf("%d\n", somar(5,3));
```

### **Ponteiros**
```c
int x = 10, *p = &x; *p = 20;        // x => 20
int *q = &x, **pp = &q; **pp = 42;   // x => 42
```

---

## ❌ Casos de Erro (diagnóstico do compilador)

> Estes arquivos ficam em `tests_c/errors/` e **devem falhar** ao compilar (ou gerar UB óbvia), validando mensagens e robustez do front-end.

- `div_zero.c` — divisão por zero.
- `dois_pontos_ausente.c` — falta `;` após declaração.
- `erro_de_ortografia.c` — `pritnf` (símbolo indefinido).
- `tipo_incorreto.c` — soma entre `int` e string literal.
- `variavel_desconhecida.c` — símbolo não declarado.
- `mal_identacao.c` — compila, mas mantém intenção de estilo ruim.

Para rodar a verificação:
```bash
./test_c_errors.sh
```

---

## 🔧 Como Testar Manualmente

### **Método 1: Teste direto de um arquivo**
```bash
gcc -Wall -Wextra -std=c11 tests_c/test_simple.c -o test_simple.out
./test_simple.out
```

### **Método 2: Outro arquivo específico**
```bash
gcc -Wall -Wextra -std=c11 tests_c/test_if.c -o test_if.out
./test_if.out
```

### **Método 3: Suíte completa (scripts)**
```bash
chmod +x run_c_tests.sh test_c_errors.sh
./run_c_tests.sh
./test_c_errors.sh
```

---

## 📊 Resultados Esperados (exemplos)

### **Teste Bem-Sucedido**
```text
z=30
```

### **Teste com Condicional**
```text
Positivo
```

### **Teste com Blocos Aninhados**
```text
A
A1
B
```

### **Ponteiros**
```text
x=20
x=42
```

### **Loop**
```text
0
1
2
```

### **Caso de Erro (compilação)**
```text
.../tipo_incorreto.c: In function ‘main’:
... error: invalid operands to binary + (have ‘int’ and ‘char *’)
```

---

## 🐛 Solução de Problemas

### **“command not found” ao rodar script**
```bash
chmod +x run_c_tests.sh test_c_errors.sh
```

### **Compilação falha por falta de GCC/Clang**
- Instale o compilador:
  - Debian/Ubuntu: `sudo apt-get install build-essential`
  - Fedora: `sudo dnf install gcc`
  - Arch: `sudo pacman -S gcc`

### **Erros de linkagem ou flags**
- Use um mínimo estável:
```bash
gcc -std=c11 -Wall -Wextra arquivo.c -o arquivo.out
```

### **Permissões no repositório**
```bash
git config --global core.filemode false
```

---

## 📈 Expandindo os Testes

### **Criar um novo teste**
```bash
cat > tests_c/test_meu_exemplo.c <<'EOF'
#include <stdio.h>
int main(void){
    printf("meu-exemplo\n");
    return 0;
}
EOF

gcc -Wall -Wextra -std=c11 tests_c/test_meu_exemplo.c -o tests_c/test_meu_exemplo.out
./tests_c/test_meu_exemplo.out
```

### **Adicionar ao script**
No `run_c_tests.sh`, inclua a compilação (o script já compila todos os `.c` do diretório raiz `tests_c/`, então basta salvar o arquivo).

---

## 🎯 Checklist de Testes

- [ ] Atribuições simples funcionam  
- [ ] Aritmética e precedência funcionam  
- [ ] Comparações e lógicos funcionam  
- [ ] `printf` imprime o esperado  
- [ ] `if / else if / else` funcionam  
- [ ] `while` funciona  
- [ ] Funções e retorno funcionam  
- [ ] Ponteiros e ponteiro de ponteiro funcionam  
- [ ] Casos de erro geram diagnósticos de compilação  

---

## 📞 Suporte

1. Confirme que o compilador está instalado (`gcc --version`).  
2. Compile um teste simples antes da suíte.  
3. Use os scripts `run_c_tests.sh` e `test_c_errors.sh`.  
4. Verifique o README/Docs do projeto para flags/ambiente.

**Versão:** Suíte C  
**Data:** _15/10/2025_
