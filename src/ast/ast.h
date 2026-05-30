#ifndef AST_H
#define AST_H

typedef enum {
// Tipos de nós temos que ir adicionando conforme a gente for implementando o parser
} TipoNo;

typedef struct NoAST {
    TipoNo tipo;          // Fala o tipo do nó (variável, operação, etc.) ex: NO_SOMA
    char *valor;          // O texto, se for um número ou variável
    struct NoAST *esq;    // Filho da esquerda
    struct NoAST *dir;    // Filho da direita
} NoAST;

// Função de criação
NoAST* criar_no(TipoNo tipo, NoAST *esq, NoAST *dir, char *valor);

// Função para debugar (ver se a árvore foi montada certa)
void imprimir_ast(NoAST *raiz, int nivel);

#endif