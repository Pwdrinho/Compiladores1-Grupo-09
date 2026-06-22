#ifndef AST_H
#define AST_H
#include "symtab.h" // pegamos o tipo Simbolo e TipoDado

// Tipos de nó que vamos usar, como o no é generico a gente vai usar esse enum pra saber o que cada nó representa
typedef enum {
    NO_PROGRAMA,
    NO_LISTA,
    NO_FUNCAO,
    NO_PARAMETRO,
    NO_TIPO,
    NO_BLOCO,

    NO_DECLARACAO,
    NO_ATRIBUICAO,
    NO_RETORNO,

    NO_IF,
    NO_WHILE,
    NO_FOR,

    NO_BINARIO, // para operações como +, -, *, /, etc.
    NO_UNARIO, // para operações como -x, !x, etc.

    NO_IDENTIFICADOR,
    NO_NUMERO,
    NO_ACESSO_VETOR,

    NO_VAZIO
} TipoNo;

// Estrutura do Nó da Arvore Sintática (AST)
typedef struct NoAST {

    TipoNo tipo; // Tipo Sintático (ex: NO_ATRIBUICAO, NO_BINARIO)
    
    char *valor; // Guarda textos literais, números ou operadores - usamos quando não utilizamos a tabela hash e para variáveis colocamos o nome intermediario
    
    TipoDado tipo_dado; // tipo de dado (ex: TIPO_DADO_INT, TIPO_DADO_FLOAT) 
                          
    Simbolo *simbolo; // ponteiro direto para a Tabela de Símbolos, não precisamos procurar a variável e aumenta a precisao e velocidade

    struct NoAST *esq; // filho esquerdo
    struct NoAST *dir; // filho direito
} NoAST;

// recebe o tipo do nó, ponteiros para os filhos, valor literal e ponteiro para o símbolo (pode ser NULL se não for variável)
NoAST* criar_no(TipoNo tipo, NoAST *esq, NoAST *dir, const char *valor, Simbolo *simbolo);

// imprime a arvore para vermos como ela ficou, tomara que so mostre bons resultados
void imprimir_ast(NoAST *raiz, int nivel);

// libera a memoria alocada para a arvore, chamamos no final do main
void liberar_ast(NoAST *raiz);

#endif