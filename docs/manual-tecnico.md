# Manual Técnico - Compilador C para Python

## Visão Geral

Este documento descreve a arquitetura, decisões de design e limitações do compilador que traduz código C para Python. O compilador foi desenvolvido utilizando Flex para análise léxica e Bison para análise sintática, implementado em linguagem C.

## Arquitetura

O compilador segue uma arquitetura em fases, onde cada fase processa o código fonte e produz uma representação intermediária para a próxima fase.

### Fases do Compilador

#### Fase 1: Análise Léxica

A análise léxica é realizada pelo Flex através do arquivo `lexer/lexer.l`. Esta fase converte o código fonte em uma sequência de tokens.

**Componentes principais:**
- Scanner gerado pelo Flex
- Reconhecimento de palavras-chave, identificadores, literais e operadores
- Tratamento de comentários (linha única `//` e múltiplas linhas `/* */`)
- Suporte a strings e caracteres com escape sequences

**Tokens reconhecidos:**
- Tipos primitivos: `int`, `float`, `char`, `void`
- Palavras-chave: `if`, `else`, `while`, `for`, `return`
- Operadores: aritméticos, relacionais, lógicos, de atribuição
- Delimitadores: parênteses, chaves, colchetes, ponto e vírgula

#### Fase 2: Análise Sintática

A análise sintática é realizada pelo Bison através do arquivo `parser/parser.y`. Esta fase valida a estrutura gramatical do programa e constrói a Árvore Sintática Abstrata (AST).

**Características:**
- Parser LALR(1) gerado pelo Bison
- Gramática baseada na sintaxe C
- Construção da AST durante o parsing através de ações semânticas
- Tratamento de precedência e associatividade de operadores

**Estrutura da gramática:**
- Unidade de tradução (programa completo)
- Declarações externas (funções e variáveis globais)
- Definições de funções
- Statements e expressões

#### Fase 3: Análise Semântica

A análise semântica é realizada em dois passos sobre a AST:

**Passo 1: Declaração de Símbolos**
- Percorre a AST coletando declarações
- Insere símbolos na tabela de símbolos
- Gerencia escopos (global, função, bloco)
- Detecta redeclarações no mesmo escopo

**Passo 2: Checagem Semântica**
- Verifica uso de variáveis antes da declaração
- Valida compatibilidade de tipos em expressões
- Verifica tipos de retorno de funções
- Detecta operações inválidas (ex: módulo com float)

**Tabela de Símbolos:**
- Implementação com hash table
- Armazena informações sobre variáveis, arrays e funções
- Campos: nome, categoria, tipo, nível de ponteiro, flag de inicialização
- Suporte a funções built-in da biblioteca padrão C (printf, scanf, etc.)

#### Fase 4: Otimização

O módulo de otimização realiza transformações na AST para melhorar o código gerado:

**Passo 1: Propagação de Constantes**
- Identifica variáveis inicializadas com valores literais
- Substitui usos de variáveis constantes por seus valores
- Invalida constantes quando reatribuídas com valores não-literais

**Passo 2: Constant Folding**
- Avalia expressões com literais em tempo de compilação
- Simplifica operações aritméticas e lógicas com constantes
- Exemplo: `2 + 3` é transformado em `5`

**Passo 3: Simplificação de Expressões**
- Aplica identidades algébricas básicas
- Exemplos: `x + 0 → x`, `x * 1 → x`, `x - x → 0`

**Passo 4: Remoção de Código Morto**
- Remove blocos condicionais com condições constantes
- Remove loops com condições sempre falsas
- Remove expressões sem efeitos colaterais

**Passo 5: Fixpoint**
- Repete os passes anteriores até convergência
- Permite propagação de constantes em cadeia

#### Fase 5: Geração de Código Python

A geração de código é realizada pelo módulo `gerador_python.c`, que percorre a AST e gera código Python equivalente.

**Características:**
- Geração recursiva baseada no tipo de nó da AST
- Conversão de tipos C para tipos Python
- Tradução de estruturas de controle (if, while, for)
- Tratamento de funções e chamadas de função
- Conversão de printf para print com f-strings

### Estrutura de Dados

#### Árvore Sintática Abstrata (AST)

A AST é uma representação hierárquica do programa fonte. Cada nó possui:

- Tipo do nó (declaração, expressão, comando, etc.)
- Tipo de dado semântico (int, float, char, ponteiro)
- Nível de escopo
- Linha do código fonte
- Dados específicos conforme o tipo de nó

**Tipos de nós principais:**
- Literais: inteiros, floats, caracteres, strings
- Identificadores: variáveis, funções
- Operadores: binários e unários
- Declarações: variáveis, arrays, funções
- Comandos: atribuição, if, while, for, return, blocos
- Estruturais: programa, listas, parâmetros

#### Tabela de Símbolos

A tabela de símbolos utiliza uma hash table para armazenar informações sobre identificadores:

- Nome do símbolo
- Categoria (variável, array, função)
- Tipo de dado
- Nível de ponteiro (para ponteiros)
- Flag de inicialização
- Encadeamento para resolução de colisões

## Decisões de Design

### Arquitetura em Fases

A separação clara entre fases permite:
- Manutenção facilitada de cada componente
- Testes independentes de cada fase
- Extensibilidade para novas funcionalidades
- Debugging mais simples através de pontos de verificação

### Representação Intermediária

**AST como representação intermediária:**
- Preserva toda a informação semântica do programa
- Facilita múltiplas passadas de análise e otimização
- Estrutura recursiva natural para geração de código
- Permite transformações antes da geração final

### Gerenciamento de Escopos

**Abordagem com pilha de escopos:**
- Implementação simples e eficiente
- Suporte a escopos aninhados (global, função, bloco)
- Busca de símbolos através dos escopos hierárquicos
- Detecção de variáveis não declaradas

### Estratégia de Otimização

**Abordagem conservadora:**
- Invalida constantes em qualquer reatribuição não-literal
- Evita análise de fluxo de controle complexa
- Garante correção mesmo sem análise profunda
- Permite implementação incremental de otimizações mais avançadas

**Múltiplos passes:**
- Permite convergência para fixpoint
- Propaga constantes em cadeia
- Aplica otimizações que dependem de outras otimizações

### Tratamento de Erros

**Mensagens de erro descritivas:**
- Indicação clara do tipo de erro
- Localização através de número de linha
- Mensagens em português para facilitar uso
- Continuação da análise quando possível para detectar múltiplos erros

## Limitações

### Funcionalidades Não Suportadas

**Tipos e Estruturas:**
- Structs e unions não são suportados
- Enums não são suportados
- Typedef não é suportado
- Apenas tipos primitivos (int, float, char) e ponteiros são suportados

**Recursos de C:**
- Macros do pré-processador (#define, #include) não são processados
- Casts explícitos não são suportados
- Operador ternário (?:) não é suportado
- Operadores de incremento/decremento (++, --) não são suportados
- Operadores compostos de atribuição (+=, -=, etc.) são reconhecidos mas não totalmente implementados

**Ponteiros:**
- Aritmética de ponteiros é limitada
- Ponteiros para funções não são suportados
- Ponteiros para ponteiros têm suporte limitado

**Arrays:**
- Arrays multidimensionais não são suportados
- Inicialização de arrays é limitada
- Arrays como parâmetros de função têm limitações

**Funções:**
- Funções variádicas não são suportadas
- Recursão pode ter limitações dependendo do caso
- Ponteiros para funções não são suportados

**Biblioteca Padrão:**
- Apenas algumas funções built-in são reconhecidas (printf, scanf, etc.)
- Headers não são processados
- Funções da biblioteca padrão não são implementadas, apenas reconhecidas

### Limitações de Otimização

**Análise de Fluxo:**
- Não realiza análise de fluxo de controle avançada
- Não detecta caminhos onde variáveis permanecem constantes
- Invalidação conservadora pode perder otimizações

**Análise Interprocedural:**
- Constantes não propagam entre funções
- Análise limitada ao escopo de função

**Análise de Ponteiros:**
- Não realiza alias analysis
- Não rastreia valores através de ponteiros

**Dead Code Elimination:**
- Remoção básica de código morto
- Não detecta código inacessível através de análise de fluxo

### Limitações de Geração de Código

**Conversão de Tipos:**
- Conversões implícitas podem não ser totalmente equivalentes entre C e Python
- Tipos de ponteiro são convertidos de forma simplificada

**Semântica:**
- Algumas diferenças de semântica entre C e Python podem não ser totalmente tratadas
- Comportamento de divisão inteira pode diferir
- Overflow de inteiros não é detectado

**Performance:**
- Código Python gerado pode não ser otimizado
- Não há otimizações específicas para Python

### Limitações de Análise

**Verificação de Tipos:**
- Verificação básica de compatibilidade
- Conversões implícitas podem mascarar erros
- Não detecta todos os casos de uso incorreto de tipos

**Verificação de Escopo:**
- Escopos aninhados são suportados, mas análise pode ser limitada em casos complexos
- Shadowing de variáveis pode não ser totalmente verificado

**Detecção de Erros:**
- Alguns erros semânticos podem não ser detectados
- Uso de variáveis não inicializadas pode não ser sempre detectado
- Divisão por zero não é detectada em tempo de compilação (apenas em alguns casos)

## Estrutura de Arquivos

```
2025.2-Compiladores-1_Grupo-10/
├── lexer/
│   └── lexer.l              # Especificação do analisador léxico (Flex)
├── parser/
│   └── parser.y              # Gramática do analisador sintático (Bison)
├── src/
│   ├── main.c                # Programa principal, orquestra as fases
│   ├── gerador_python.c      # Geração de código Python
│   ├── gerador_python.h      # Interface do gerador
│   ├── tabela_simbolos/
│   │   ├── tabela.c          # Implementação da tabela de símbolos
│   │   ├── tabela.h          # Interface da tabela de símbolos
│   │   ├── ast.c             # Implementação da AST
│   │   ├── ast.h             # Definição da AST
│   │   └── tipos.h           # Definições de tipos
│   └── otimizador/
│       ├── otimizador.c      # Implementação das otimizações
│       └── otimizador.h      # Interface do otimizador
├── tests/                    # Casos de teste
├── Makefile                  # Automação da compilação
└── docs/                     # Documentação
```

## Fluxo de Execução

1. **Inicialização**: Carrega funções built-in na tabela de símbolos
2. **Fase 1 - Análise Léxica e Sintática**: Flex converte código fonte em tokens, Bison valida estrutura e constrói AST
3. **Fase 2 - Tabela de Símbolos**: Exibe estado atual da tabela de símbolos
4. **Fase 3 - Análise Semântica**: 
   - Passo 1: Declaração de símbolos (coleta declarações da AST)
   - Passo 2: Checagem semântica (valida uso de símbolos e tipos)
5. **Fase 4 - Otimização**: Múltiplas passadas na AST para aplicar otimizações
6. **Fase 5 - Geração de Código**: Percorre AST e gera código Python
7. **Finalização**: Libera memória e fecha arquivos

## Considerações de Implementação

### Gerenciamento de Memória

- Alocação dinâmica para nós da AST
- Strings são duplicadas para evitar problemas com buffer do Flex
- Liberação recursiva da AST ao final
- Tabela de símbolos utiliza hash table com encadeamento

### Tratamento de Erros

- Erros sintáticos são reportados pelo Bison
- Erros semânticos são detectados durante análise semântica
- Compilação pode continuar para detectar múltiplos erros
- Mensagens de erro incluem localização (linha)

### Extensibilidade

A arquitetura permite extensões futuras:
- Novos tipos de nós na AST podem ser adicionados
- Novas otimizações podem ser implementadas como passes adicionais
- Novos tipos de dados podem ser adicionados ao sistema de tipos
- Novas construções sintáticas podem ser adicionadas à gramática
