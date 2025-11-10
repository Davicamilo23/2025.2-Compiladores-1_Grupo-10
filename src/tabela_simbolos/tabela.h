#ifndef TABELA_H
#define TABELA_H

#include "tipos.h"
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
    Tipo tipo;            // Tipo do símbolo (int, float, char, void)
    int inicializada;     // Flag para verificar se foi inicializada (0=não, 1=sim)
    int nivel_ponteiro;   // Níveis de indireção de ponteiro (0 = não é ponteiro)
    struct simbolo *proximo; // Ponteiro para o próximo símbolo (para o encadeamento)
} Simbolo;

// Funções que manipulam a tabela de símbolos
void inicializarBuiltins();  // ⭐ NOVA: Inicializa funções built-in da biblioteca padrão C
void inserirSimbolo(char *nome, Categoria categoria);
void inserirSimboloTipado(char *nome, Categoria categoria, Tipo tipo, int nivel_ponteiro);
Simbolo *buscarSimbolo(char *nome);
void marcarInicializada(char *nome);
int verificarInicializada(char *nome);
Tipo obterTipo(char *nome);
const char* tipoParaString(Tipo tipo);
void imprimirTabela();

#endif