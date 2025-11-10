/* tipos.h
 * Definições centralizadas de tipos
 * 
 */

#ifndef TIPOS_H
#define TIPOS_H

/* Enum para os tipos de dados */
typedef enum {
    TIPO_INT,
    TIPO_FLOAT,
    TIPO_CHAR,
    TIPO_VOID,
    TIPO_DESCONHECIDO
} Tipo;

/* Função auxiliar para converter Tipo em string */
const char* tipoParaString(Tipo t);

#endif /* TIPOS_H */
