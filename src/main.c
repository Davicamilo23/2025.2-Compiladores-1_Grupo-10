/* main.c
 * Programa principal do compilador C -> Python
 * 
 * Este arquivo junta todas as partes:
 * - Lexer (lexer.l)
 * - Parser (parser.y)
 * - Tabela de símbolos
 * - AST
 * - Gerador Python
 */

#include <stdio.h>
#include <stdlib.h>
#include "tabela_simbolos/tabela.h"
#include "tabela_simbolos/ast.h"
#include "gerador_python.h"
#include "otimizador/otimizador.h"

// Funções do Bison/Flex
extern int yyparse(void);
extern FILE *yyin;
extern int yylineno;

// Variável global para armazenar a AST raiz
// Esta variável é populada pelo parser.y nas ações semânticas
Ast *ast_raiz = NULL; 

int main(int argc, char *argv[]) {
    printf("====================================\n");
    printf("  COMPILADOR C -> PYTHON\n");
    printf("  \n");
    printf("====================================\n\n");
    
    // ⭐ INICIALIZAR FUNÇÕES BUILT-IN DA BIBLIOTECA PADRÃO C
    // Deve ser feito ANTES de qualquer análise começar
    inicializarBuiltins();
    
    // Configurar entrada
    if (argc > 1) {
        // Ler de arquivo
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            fprintf(stderr, "Erro: Não foi possível abrir o arquivo '%s'\n", argv[1]);
            return 1;
        }
        yyin = f;
        printf("📖 Lendo arquivo: %s\n\n", argv[1]);
    } else {
        // Ler de stdin
        yyin = stdin;
        printf("📖 Lendo da entrada padrão (stdin)\n");
        printf("   Digite o código C e pressione Ctrl+D quando terminar:\n\n");
    }
    
    // FASE 1: ANÁLISE SINTÁTICA
    printf("🔍 FASE 1: Análise Léxica e Sintática\n");
    printf("--------------------------------------\n");
    
    int resultado = yyparse();
    
    if (resultado != 0) {
        fprintf(stderr, "\n❌ ERRO: Análise sintática falhou!\n");
        fprintf(stderr, "   O código contém erros de sintaxe.\n");
        return 1;
    }
    
    printf("\n✅ Análise sintática concluída com sucesso!\n\n");
    
    // FASE 2: TABELA DE SÍMBOLOS
    printf("📊 FASE 2: Tabela de Símbolos\n");
    printf("--------------------------------------\n");
    imprimirTabela();
    printf("\n");
    
    // FASE 3: AST E ANÁLISE SEMÂNTICA
    if (ast_raiz != NULL) {
        printf("🌳 FASE 3A: Árvore Sintática Abstrata (AST)\n");
        printf("--------------------------------------\n");
        printf("Estrutura da AST gerada:\n\n");
        imprimirAst(ast_raiz, 0);
        printf("\n✅ AST criada com sucesso!\n\n");
        
        printf("🔬 FASE 3B: Análise Semântica\n");
        printf("--------------------------------------\n");
        
        // Passo B: Declarar símbolos
        printf("Passo B: Declarando símbolos...\n");
        passoDeclararSimbolos(ast_raiz);
        
        // Passo C: Checagem semântica
        printf("Passo C: Checagem semântica...\n");
        passoChecagemSemantica(ast_raiz);
        
        printf("✅ Análise semântica concluída!\n\n");
        
        // FASE 3C: OTIMIZAÇÃO
        printf("🚀 FASE 3C: Otimização (Propagação de Constantes)\n");
        printf("--------------------------------------\n");
        
        // Inicializar tabela de constantes
        inicializarTabelaConstantes();
        
        // Passe 1: Propagação de constantes
        printf("Passe 1: Propagação de constantes...\n");
        ast_raiz = passePropagacaoConstantes(ast_raiz);
        
        // Passe 2: Constant folding
        printf("Passe 2: Constant folding...\n");
        ast_raiz = passeConstantFolding(ast_raiz);
        
        // Passe 3: Simplificação de expressões
        printf("Passe 3: Simplificação de expressões...\n");
        ast_raiz = passeSimplificacaoExpressoes(ast_raiz);
        
        // Passe 4: Repetir para fixpoint (propagação em cadeia)
        printf("Passe 4: Fixpoint (segunda iteração)...\n");
        ast_raiz = passePropagacaoConstantes(ast_raiz);
        ast_raiz = passeConstantFolding(ast_raiz);
        ast_raiz = passeSimplificacaoExpressoes(ast_raiz);
        
        // Exibir estatísticas
        printf("\n");
        imprimirEstatisticasOtimizacao();
        
        // Limpar tabela de constantes
        limparTabelaConstantes();
        
        printf("✅ Otimização concluída!\n\n");
        
        // FASE 4: GERAÇÃO DE CÓDIGO PYTHON
        printf("🐍 FASE 4: Geração de Código Python\n");
        printf("--------------------------------------\n");
        
        const char *arquivo_saida = "saida.py";
        gerarCodigoPython(ast_raiz, arquivo_saida);
        
        printf("\n✅ Compilação concluída!\n");
        printf("   Arquivo gerado: %s\n", arquivo_saida);
        printf("\n💡 Para executar o código Python:\n");
        printf("   python3 %s\n", arquivo_saida);
        
    } else {
        printf("⚠️  AVISO: AST não foi criada pelo parser\n");
        printf("   A geração de código Python foi pulada.\n");
        printf("\n   POSSÍVEIS CAUSAS:\n");
        printf("   1. O código de entrada está vazio\n");
        printf("   2. Houve erro na criação dos nós da AST\n");
        printf("   3. O parser.y não está atribuindo à variável ast_raiz\n");
    }
    
    printf("\n====================================\n");
    printf("  FIM DA COMPILAÇÃO\n");
    printf("====================================\n");
    
    // Limpar memória
    if (ast_raiz != NULL) {
        liberarAst(ast_raiz);
    }
    
    // Fechar arquivo se foi aberto
    if (argc > 1) {
        fclose(yyin);
    }
    
    return 0;
}