#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

// Cria um nó na árvore, recebendo o tipo, p filho da esquerda, o filho da direta e o valor (se for um número ou variável)
NoAST* criar_no(TipoNo tipo, NoAST *esq, NoAST *dir, char *valor) { 
    
    NoAST *novo = (NoAST*) malloc(sizeof(NoAST)); // memoria para o novo nó
    if (!novo) return NULL; // verifica a alocação da memoria

    // Preenche os campos
    novo->tipo = tipo;
    novo->esq = esq;
    novo->dir = dir;
    novo->valor = valor;

    return novo;
}

// Função pra mostrar a arvore, vamos usar pra debugar
void imprimir_ast(NoAST *raiz, int nivel) {
    if (raiz == NULL) return;

    // Faz um recuo baseado no nível da árvore para ficar visualmente bonito
    for (int i = 0; i < nivel; i++) printf("  ");

    // Imprime o tipo do nó
    printf("Nó: %d (Valor: %s)\n", raiz->tipo, raiz->valor ? raiz->valor : "NULL");

    // Chama recursivamente para os filhos
    imprimir_ast(raiz->esq, nivel + 1);
    imprimir_ast(raiz->dir, nivel + 1);
}