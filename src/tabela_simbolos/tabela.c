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
    inserirSimboloTipado(nome, categoria, TIPO_DESCONHECIDO, 0);
}

// Função para inserir um símbolo com informações de tipo
void inserirSimboloTipado(char *nome, Categoria categoria, Tipo tipo, int nivel_ponteiro) {
    // Verifica se o símbolo já está na tabela
    if (buscarSimbolo(nome) != NULL) {
        printf("Erro semântico: Redeclaração da variável '%s'.\n", nome);
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
    s->tipo = tipo;
    s->inicializada = 0;  // Por padrão, não inicializada
    s->nivel_ponteiro = nivel_ponteiro;
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