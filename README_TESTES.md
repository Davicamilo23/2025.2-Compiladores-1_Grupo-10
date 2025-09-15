# 🧪 Guia de Testes - Compilador Python-like

## Como Executar os Testes

### 🚀 Início Rápido

1. **Compilar o projeto:**
   ```bash
   make clean && make
   ```

2. **Executar bateria de testes:**
   ```bash
   ./run_tests.sh
   ```

3. **Testar casos de erro:**
   ```bash
   ./test_errors.sh
   ```

---

## 📁 Estrutura de Testes

```
tests/
├── test_simple.py      # Atribuições básicas
├── test_print.py       # Comandos print
├── test_basic.py       # Teste com comentários
├── test_if.py          # Estruturas condicionais (limitado)
├── test_while.py       # Loops (limitado)
├── test_function.py    # Definições de função (limitado)
└── test_error.py       # Erros sintáticos intencionais

Scripts de Teste:
├── run_tests.sh        # Bateria principal de testes
├── test_errors.sh      # Testes de casos de erro
├── teste_manual.sh     # Menu interativo
└── exemplos_teste.sh   # Exemplos com feedback visual
```

---

## ✅ Casos de Teste que Funcionam

### **Atribuições Simples**
```python
x = 10
nome = "João"
flag = True
```

### **Expressões Aritméticas**
```python
resultado = 5 + 3 * 2
valor = (10 + 5) * 2
calculo = x // y + z % w
```

### **Expressões Lógicas**
```python
condicao = True and False
check = not flag
teste = x > 0 or y < 10
```

### **Comparações**
```python
igual = x == y
diferente = a != b
maior = num >= limite
```

### **Comando Print**
```python
print("Hello World")
print("Resultado:")
```

---

## ❌ Casos que Ainda Não Funcionam

### **Estruturas com Blocos Indentados**
```python
# Não funciona ainda
if x > 0:
    print("Positivo")

while x < 10:
    x = x + 1

def funcao():
    return True
```

### **Comentários em Arquivos**
```python
# Comentários podem causar problemas em alguns casos
x = 10  # Comentário inline
```

---

## 🔧 Como Testar Manualmente

### **Método 1: Teste Direto**
```bash
echo "x = 5 + 3" | ./pylite
```

### **Método 2: Teste Interativo**
```bash
./pylite
# Digite: x = 10
# Pressione: Ctrl+D
```

### **Método 3: Teste com Arquivo**
```bash
echo "resultado = 2 * 3" > meu_teste.py
./pylite < meu_teste.py
```

### **Método 4: Menu Interativo**
```bash
./teste_manual.sh
# Escolha uma opção do menu
```

---

## 📊 Resultados Esperados

### **Teste Bem-Sucedido**
```bash
$ echo "x = 10" | ./pylite
assign x := expr
[OK] programa reconhecido
```

### **Teste com Print**
```bash
$ echo 'print("Hello")' | ./pylite
print(...)
[OK] programa reconhecido
```

### **Teste com Erro**
```bash
$ echo "x = 5 @@ 2" | ./pylite
Unexpected character: @
Unexpected character: @
assign x := expr
[SINTAXE] erro: syntax error
```

---

## 🐛 Solução de Problemas

### **Erro: "command not found"**
```bash
# Verificar se o projeto foi compilado
make clean && make

# Verificar se o executável existe
ls -la pylite
```

### **Erro: "syntax error" inesperado**
```bash
# Verificar se o código está na sintaxe suportada
# Evitar estruturas com indentação por enquanto
```

### **Erro: Script não executa**
```bash
# Dar permissão de execução
chmod +x run_tests.sh
chmod +x test_errors.sh
chmod +x teste_manual.sh
chmod +x exemplos_teste.sh
```

---

## 📈 Expandindo os Testes

### **Criar Novos Testes**
```bash
# Criar arquivo de teste
echo "meu_codigo = True" > tests/meu_teste.py

# Testar
./pylite < tests/meu_teste.py
```

### **Adicionar ao Script de Testes**
Edite `run_tests.sh` e adicione:
```bash
echo "N. Meu novo teste:"
echo "   Arquivo: meu_teste.py"
cat tests/meu_teste.py
echo "   Resultado:"
./pylite < tests/meu_teste.py
echo ""
```

---

## 🎯 Checklist de Testes

- [ ] Atribuições simples funcionam
- [ ] Expressões aritméticas funcionam
- [ ] Operadores lógicos funcionam
- [ ] Comparações funcionam
- [ ] Print funciona
- [ ] Parênteses funcionam
- [ ] Erros são detectados
- [ ] Caracteres inválidos são rejeitados

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique se o projeto compila sem erros
2. Teste com exemplos simples primeiro
3. Use os scripts de teste fornecidos
4. Consulte a documentação completa em `DOCUMENTACAO_SPRINT1.md`

**Versão:** Sprint 1  
**Data:** 13-14 de Setembro de 2025
