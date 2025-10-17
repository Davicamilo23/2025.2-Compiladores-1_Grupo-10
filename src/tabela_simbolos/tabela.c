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
        h = (h << 4) + *s++;  // Aplica uma transformação simples de hash
    }
    return h % TAM;  // Garante que o valor do hash fique dentro do tamanho da tabela
}

// Função para inserir um símbolo na tabela
void inserirSimbolo(char *nome, Categoria categoria) {
    // Verifica se o símbolo já está na tabela
    if (buscarSimbolo(nome) != NULL) {
        printf("Erro: Símbolo '%s' já está na tabela.\n", nome);
        return;
    }

    unsigned i = hash(nome);  // Obtém o índice para a tabela de hash
    Simbolo *s = malloc(sizeof(Simbolo));  // Aloca memória para o novo símbolo

    if (!s) {  // Verifica se a alocação foi bem-sucedida
        printf("Erro ao alocar memória para o símbolo.\n");
        return;
    }

    // Preenche os dados do símbolo
    strcpy(s->nome, nome);
    s->categoria = categoria;
    s->proximo = tabela[i];  // Insere o símbolo no início da lista encadeada
    tabela[i] = s;  // Atualiza o índice na tabela
}

// Função para buscar um símbolo na tabela
Simbolo *buscarSimbolo(char *nome) {
    unsigned i = hash(nome);  // Obtém o índice para a tabela de hash
    for (Simbolo *s = tabela[i]; s; s = s->proximo) {  // Percorre a lista encadeada
        if (strcmp(s->nome, nome) == 0)  // Verifica se o nome do símbolo coincide
            return s;  // Retorna o símbolo encontrado
    }
    return NULL;  // Retorna NULL caso o símbolo não seja encontrado
}

// Função para imprimir a tabela de símbolos
void imprimirTabela() {
    printf("Tabela de Símbolos:\n");
    printf("----------------------\n");
    for (int i = 0; i < TAM; i++) {
        for (Simbolo *s = tabela[i]; s; s = s->proximo) {
            printf("Nome: %-32s | Categoria: %-10s\n", s->nome, 
                   s->categoria == CATEGORIA_VARIAVEL ? "Variável" : 
                   (s->categoria == CATEGORIA_ARRAY ? "Array" : "Função"));
        }
    }
}