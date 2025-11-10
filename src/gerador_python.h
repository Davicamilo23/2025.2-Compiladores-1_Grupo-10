/* gerador_python.h
 * Header do gerador de código Python
 */

#ifndef GERADOR_PYTHON_H
#define GERADOR_PYTHON_H

#include "tabela_simbolos/ast.h"

/**
 * Gera código Python a partir da AST
 * 
 * @param ast_raiz Nó raiz da AST (geralmente AST_PROGRAMA)
 * @param arquivo_saida Nome do arquivo de saída (ou NULL para stdout)
 * 
 * Exemplo de uso:
 *   Ast *raiz = ... // obtida do parser
 *   gerarCodigoPython(raiz, "saida.py");
 */
void gerarCodigoPython(Ast *ast_raiz, const char *arquivo_saida);

#endif // GERADOR_PYTHON_H