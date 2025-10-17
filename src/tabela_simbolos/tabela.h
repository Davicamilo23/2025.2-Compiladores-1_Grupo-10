#ifndef TABELA_H
#define TABELA_H

#include "ast.h"

// Definição da categoria do símbolo (variável, array ou função)
typedef enum {
    CATEGORIA_VARIAVEL,
    CATEGORIA_ARRAY,
    CATEGORIA_FUNCAO
} Categoria;

// Definição da estrutura Simbolo
typedef struct simbolo {
    char nome[32];        // Nome do símbolo
    Categoria categoria;  // Categoria do símbolo (variável, array ou função)
    struct simbolo *proximo; // Ponteiro para o próximo símbolo (para o encadeamento)
} Simbolo;

// Funções que manipulam a tabela de símbolos
void inserirSimbolo(char *nome, Categoria categoria);
Simbolo *buscarSimbolo(char *nome);
void imprimirTabela();

#endif