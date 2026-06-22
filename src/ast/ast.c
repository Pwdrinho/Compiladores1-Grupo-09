#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

// copia os valores das memorias temporarias para o valor do nó
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

// Cria um nó para a AST
NoAST* criar_no(TipoNo tipo, NoAST *esq, NoAST *dir, const char *valor, Simbolo *simbolo) {
    NoAST *novo = malloc(sizeof(NoAST));

    if (novo == NULL) {
        return NULL; // Falha de alocação
    }

    // Preenchemos os dados sintáticos básicos
    novo->tipo = tipo;
    novo->esq = esq;
    novo->dir = dir;
    novo->valor = copiar_string(valor);

    // Colocamos o ponteiro para a exata localização da variável na tabela de símbolos
    novo->simbolo = simbolo; 
    
    // Inicializamos o tipo de dado como nulo/vazio, ele será preenchido depois pelo analisador semântico 
    novo->tipo_dado = TIPO_DADO_VOID; 

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

static const char *nome_tipo_dado(TipoDado tipo) {
    switch (tipo) {
        case TIPO_DADO_VOID: return "TIPO_DADO_VOID";
        case TIPO_DADO_INT: return "TIPO_DADO_INT";
        case TIPO_DADO_FLOAT: return "TIPO_DADO_FLOAT";

        default: return "TIPO_DADO_DESCONHECIDO";
    }
}

// // imprime a arvore
// void imprimir_ast(NoAST *raiz, int nivel) {
//     if (raiz == NULL) {
//         return;
//     }

//     // Imprime os espaços baseados no nível
//     for (int i = 0; i < nivel; i++) {
//         printf("  ");
//     }

//     printf("endereco=%p | tipo=%s", (void *) raiz, nome_tipo_no(raiz->tipo));
    
//     // Mostra o valor se existir
//     if (raiz->valor != NULL) {
//         printf(" | valor='%s'", raiz->valor);
//     }

//     // Mostra se o nó está amarrado a um símbolo na tabela
//     if (raiz->simbolo != NULL) {
//         printf(" | SIMBOLO=[Ativo]");
//     }

//     // mostra o tipo de dado
//     printf(" | tipo_dado=%s", nome_tipo_dado(raiz->tipo_dado));

//     printf("\n");

//     imprimir_ast(raiz->esq, nivel + 1);
//     imprimir_ast(raiz->dir, nivel + 1);
// }

// imprime arvore sintatica - com galhos (frescura da minha parte, mas ficou bonito e ajuda a visualizar melhor)
static void imprimir_ast_arvore(NoAST *raiz, int nivel, int *niveis_fechados) {
    if (raiz == NULL) {
        return;
    }

    // imprime as linhas verticais e as bifurcações dos galhos
    for (int i = 0; i < nivel; i++) {
        if (i == nivel - 1) {
            // É o último nível antes do nó atual, decide se é bifurcação ou final
            if (niveis_fechados[i]) {
                printf("└── ");
            } else {
                printf("├── ");
            }
        } else {
            // Níveis anteriores, decide se desce a linha reta ou espaço vazio
            if (niveis_fechados[i]) {
                printf("    ");
            } else {
                printf("│   ");
            }
        }
    }

    // imprime os dados estruturais do nó (Idêntico ao seu original)
    // printf("endereco=%p | tipo=%s", (void *) raiz, nome_tipo_no(raiz->tipo));
    printf("tipo=%s", nome_tipo_no(raiz->tipo));
    
    if (raiz->valor != NULL) {
        printf(" | valor='%s'", raiz->valor);
    }
    if (raiz->simbolo != NULL) {
        printf(" | SIMBOLO=[Ativo]");
    }
    printf(" | tipo_dado=%s\n", nome_tipo_dado(raiz->tipo_dado));

    // verifica os filhos para ditar a regra do próximo nível
    int tem_esq = (raiz->esq != NULL);
    int tem_dir = (raiz->dir != NULL);

    if (tem_esq) {
        // Se também existe um filho à direita, o da esquerda NÃO fecha o galho atual (0)
        niveis_fechados[nivel] = tem_dir ? 0 : 1;
        imprimir_ast_arvore(raiz->esq, nivel + 1, niveis_fechados);
    }
    
    if (tem_dir) {
        // O filho da direita sempre será o último deste nó, então ele FECHA o galho (1)
        niveis_fechados[nivel] = 1;
        imprimir_ast_arvore(raiz->dir, nivel + 1, niveis_fechados);
    }
}

// Função principal de entrada
void imprimir_ast(NoAST *raiz, int nivel) {
    // Vetor que atua como memória histórica para saber quais galhos já foram "fechados".
    int niveis_fechados[2048] = {0}; 
    
    // Inicia a impressão recursiva
    imprimir_ast_arvore(raiz, nivel, niveis_fechados);
}

// libera a memoria alocada para a arvore
void liberar_ast(NoAST *raiz) {
    if (raiz == NULL) {
        return;
    }

    liberar_ast(raiz->esq);
    liberar_ast(raiz->dir);

    if (raiz->valor != NULL) {
        free(raiz->valor);
    }
    
    free(raiz);
}