#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/*
 * Copia uma string para memória nova.
 *
 * Isso é importante porque valores vindos do lexer/parser podem mudar
 * ou deixar de existir depois da leitura de novos tokens.
 */
static char *copiar_string(const char *texto) {
    if (texto == NULL) {
        return NULL;
    }

    char *copia = malloc(strlen(texto) + 1);

    if (copia == NULL) {
        return NULL;
    }

    strcpy(copia, texto);
    return copia;
}

/*
 * Cria um novo nó da árvore sintática.
 */
NoAST* criar_no(TipoNo tipo, NoAST *esq, NoAST *dir, const char *valor) {
    NoAST *novo = malloc(sizeof(NoAST));

    if (novo == NULL) {
        return NULL;
    }

    novo->tipo = tipo;
    novo->esq = esq;
    novo->dir = dir;
    novo->valor = copiar_string(valor);

    return novo;
}


static const char *nome_tipo_no(TipoNo tipo) {
    switch (tipo) {
        case NO_PROGRAMA: return "NO_PROGRAMA";
        case NO_LISTA: return "NO_LISTA";
        case NO_FUNCAO: return "NO_FUNCAO";
        case NO_PARAMETRO: return "NO_PARAMETRO";
        case NO_TIPO: return "NO_TIPO";
        case NO_BLOCO: return "NO_BLOCO";

        case NO_DECLARACAO: return "NO_DECLARACAO";
        case NO_ATRIBUICAO: return "NO_ATRIBUICAO";
        case NO_RETORNO: return "NO_RETORNO";

        case NO_IF: return "NO_IF";
        case NO_WHILE: return "NO_WHILE";
        case NO_FOR: return "NO_FOR";

        case NO_BINARIO: return "NO_BINARIO";
        case NO_UNARIO: return "NO_UNARIO";

        case NO_IDENTIFICADOR: return "NO_IDENTIFICADOR";
        case NO_NUMERO: return "NO_NUMERO";
        case NO_ACESSO_VETOR: return "NO_ACESSO_VETOR";

        case NO_VAZIO: return "NO_VAZIO";

        default: return "NO_DESCONHECIDO";
    }
}

/*
 * Imprime a AST com indentação.
 *
 * Cada nível da árvore recebe dois espaços de recuo.
 */
void imprimir_ast(NoAST *raiz, int nivel) {
    if (raiz == NULL) {
        return;
    }

    (void)nivel;

    printf("endereco=%p | tipo=%s",
           (void *) raiz,
           nome_tipo_no(raiz->tipo));

    printf(" | esq=");
    if (raiz->esq != NULL) {
        printf("%p", (void *) raiz->esq);
    } else {
        printf("NULL");
    }

    printf(" | dir=");
    if (raiz->dir != NULL) {
        printf("%p", (void *) raiz->dir);
    } else {
        printf("NULL");
    }

    printf("\n");

    imprimir_ast(raiz->esq, nivel + 1);
    imprimir_ast(raiz->dir, nivel + 1);
}

/*
 * Libera recursivamente a memória da árvore.
 *
 * Primeiro libera os filhos, depois o próprio nó.
 */
void liberar_ast(NoAST *raiz) {
    if (raiz == NULL) {
        return;
    }

    liberar_ast(raiz->esq);
    liberar_ast(raiz->dir);

    free(raiz->valor);
    free(raiz);
}