#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "tabela.h"

#define TAM 211  // Tamanho da tabela de hash

// Tabela de símbolos (hash table)
Simbolo *tabela[TAM];

// Função para calcular o valor de hash
unsigned hash(char *s) {
    unsigned h = 0;
    while (*s) {
        h = (h << 4) + *s++;
    }
    return h % TAM;
}

// ===== NOVA FUNÇÃO: Inicializar funções built-in =====
void inicializarBuiltins() {
    // printf - função variádica que retorna int
    Simbolo *printf_sym = malloc(sizeof(Simbolo));
    strcpy(printf_sym->nome, "printf");
    printf_sym->categoria = CATEGORIA_FUNCAO;
    printf_sym->tipo = TIPO_INT;
    printf_sym->inicializada = 1;  // Built-ins são "pré-inicializadas"
    printf_sym->nivel_ponteiro = 0;
    unsigned i = hash("printf");
    printf_sym->proximo = tabela[i];
    tabela[i] = printf_sym;

    // scanf - função variádica que retorna int
    Simbolo *scanf_sym = malloc(sizeof(Simbolo));
    strcpy(scanf_sym->nome, "scanf");
    scanf_sym->categoria = CATEGORIA_FUNCAO;
    scanf_sym->tipo = TIPO_INT;
    scanf_sym->inicializada = 1;
    scanf_sym->nivel_ponteiro = 0;
    i = hash("scanf");
    scanf_sym->proximo = tabela[i];
    tabela[i] = scanf_sym;

    // puts - retorna int
    Simbolo *puts_sym = malloc(sizeof(Simbolo));
    strcpy(puts_sym->nome, "puts");
    puts_sym->categoria = CATEGORIA_FUNCAO;
    puts_sym->tipo = TIPO_INT;
    puts_sym->inicializada = 1;
    puts_sym->nivel_ponteiro = 0;
    i = hash("puts");
    puts_sym->proximo = tabela[i];
    tabela[i] = puts_sym;

    // malloc - retorna void*
    Simbolo *malloc_sym = malloc(sizeof(Simbolo));
    strcpy(malloc_sym->nome, "malloc");
    malloc_sym->categoria = CATEGORIA_FUNCAO;
    malloc_sym->tipo = TIPO_VOID;
    malloc_sym->inicializada = 1;
    malloc_sym->nivel_ponteiro = 1;  // Retorna ponteiro
    i = hash("malloc");
    malloc_sym->proximo = tabela[i];
    tabela[i] = malloc_sym;

    // free - retorna void
    Simbolo *free_sym = malloc(sizeof(Simbolo));
    strcpy(free_sym->nome, "free");
    free_sym->categoria = CATEGORIA_FUNCAO;
    free_sym->tipo = TIPO_VOID;
    free_sym->inicializada = 1;
    free_sym->nivel_ponteiro = 0;
    i = hash("free");
    free_sym->proximo = tabela[i];
    tabela[i] = free_sym;
}

// Função para inserir um símbolo na tabela
void inserirSimbolo(char *nome, Categoria categoria) {
    inserirSimboloTipado(nome, categoria, TIPO_DESCONHECIDO, 0);
}

// Função para inserir um símbolo com informações de tipo
void inserirSimboloTipado(char *nome, Categoria categoria, Tipo tipo, int nivel_ponteiro) {
    // Verifica se o símbolo já está na tabela
    Simbolo *existente = buscarSimbolo(nome);
    if (existente != NULL) {
        // Permite redeclaração se for uma built-in (não mostra erro)
        if (existente->inicializada == 1 && existente->categoria == CATEGORIA_FUNCAO) {
            return;  // Ignora silenciosamente
        }
        printf("Erro semântico: Redeclaração da variável '%s'.\n", nome);
        return;
    }

    unsigned i = hash(nome);
    Simbolo *s = malloc(sizeof(Simbolo));

    if (!s) {
        printf("Erro ao alocar memória para o símbolo.\n");
        return;
    }

    strcpy(s->nome, nome);
    s->categoria = categoria;
    s->tipo = tipo;
    s->inicializada = 0;
    s->nivel_ponteiro = nivel_ponteiro;
    s->proximo = tabela[i];
    tabela[i] = s;
}

// Função para buscar um símbolo na tabela
Simbolo *buscarSimbolo(char *nome) {
    unsigned i = hash(nome);
    for (Simbolo *s = tabela[i]; s; s = s->proximo) {
        if (strcmp(s->nome, nome) == 0)
            return s;
    }
    return NULL;
}

// Função para marcar um símbolo como inicializado
void marcarInicializada(char *nome) {
    Simbolo *s = buscarSimbolo(nome);
    if (s != NULL) {
        s->inicializada = 1;
    }
}

// Função para verificar se um símbolo foi inicializado
int verificarInicializada(char *nome) {
    Simbolo *s = buscarSimbolo(nome);
    if (s != NULL) {
        return s->inicializada;
    }
    return 0;
}

// Função para obter o tipo de um símbolo
Tipo obterTipo(char *nome) {
    Simbolo *s = buscarSimbolo(nome);
    if (s != NULL) {
        return s->tipo;
    }
    return TIPO_DESCONHECIDO;
}

// Função para converter tipo para string (para mensagens de erro)
const char* tipoParaString(Tipo tipo) {
    switch (tipo) {
        case TIPO_INT:
            return "int";
        case TIPO_FLOAT:
            return "float";
        case TIPO_CHAR:
            return "char";
        case TIPO_VOID:
            return "void";
        case TIPO_DESCONHECIDO:
        default:
            return "desconhecido";
    }
}

// Função para imprimir a tabela de símbolos
void imprimirTabela() {
    printf("\n=== TABELA DE SÍMBOLOS ===\n");
    printf("%-20s | %-12s | %-10s | %-12s | %-10s\n", 
           "Nome", "Categoria", "Tipo", "Inicializada", "Ptr Level");
    printf("-------------------------------------------------------------------------\n");
    
    for (int i = 0; i < TAM; i++) {
        for (Simbolo *s = tabela[i]; s; s = s->proximo) {
            const char *cat = (s->categoria == CATEGORIA_VARIAVEL) ? "Variável" : 
                             (s->categoria == CATEGORIA_ARRAY) ? "Array" : "Função";
            const char *tipo = tipoParaString(s->tipo);
            const char *init = s->inicializada ? "Sim" : "Não";
            
            printf("%-20s | %-12s | %-10s | %-12s | %-10d\n", 
                   s->nome, cat, tipo, init, s->nivel_ponteiro);
        }
    }
    printf("==========================\n\n");
}