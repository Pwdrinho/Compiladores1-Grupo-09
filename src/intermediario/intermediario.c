#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "intermediario.h"

// Contador global oculto para gerar temporários (t0, t1, t2...)
static int contador_temporarios = 0;

char* criar_temp() {
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "t%d", contador_temporarios++);
    return strdup(buffer);
}

// cria uma instrução atomicamente
Intermediario* intermediario_criar(TipoIntermediario tipo, const char *res, const char *op1, const char *op2) {
    Intermediario *inst = malloc(sizeof(Intermediario));
    inst->tipo = tipo;
    inst->resultado = res ? strdup(res) : NULL;
    inst->operador1 = op1 ? strdup(op1) : NULL;
    inst->operador2 = op2 ? strdup(op2) : NULL;
    inst->anterior = NULL;
    inst->proximo = NULL;
    return inst;
}

// Une duas listas de instruções
Intermediario* intermediario_juntar(Intermediario *l1, Intermediario *l2) {
    if (l1 == NULL) return l2;
    if (l2 == NULL) return l1;

    Intermediario *atual = l1;
    while (atual->proximo != NULL) {
        atual = atual->proximo;
    }
    
    atual->proximo = l2;
    l2->anterior = atual;
    
    return l1; // Retorna o início da lista combinada
}

Intermediario* gerar_codigo_intermediario(NoAST *no) {
    if (no == NULL) return NULL;

    // vai nos filhos e junta os códigos que eles gerarem
    Intermediario *codigo_esq = gerar_codigo_intermediario(no->esq);
    Intermediario *codigo_dir = gerar_codigo_intermediario(no->dir);
    Intermediario *codigo_atual = intermediario_juntar(codigo_esq, codigo_dir);

    // avalia o nó atual
    switch (no->tipo) {
        
        case NO_NUMERO:
            // é a folha, o valor já esté em no->valor
            break;

        case NO_IDENTIFICADOR:
            // Substitui o nome original (ex: "x") pelo nome intermediario (ex: "x_0")
            if (no->simbolo != NULL) {
                if (no->valor != NULL) free(no->valor);
                no->valor = strdup(no->simbolo->nome_intermediario);
            }
            break;

        case NO_DECLARACAO: {
            char *destino = no->simbolo->nome_intermediario;
            Intermediario *instrucao = intermediario_criar(INTER_DECLARACAO, destino, NULL, NULL);
            instrucao->tipo_variavel = no->simbolo->tipo_dado;
            // A declaração deveria vir antes de uma possível atribuição
            codigo_atual = intermediario_juntar(instrucao, codigo_atual);
            break;
        }

        case NO_ATRIBUICAO: {
            // O filho esquerdo já preencheu seu no->valor com o "x_0"
            // O filho direito já preencheu seu no->valor com o valor ou temporário
            char *destino = no->esq->valor;
            char *origem = no->dir->valor;
            
            Intermediario *instrucao = intermediario_criar(INTER_ATRIBUICAO, destino, origem, NULL);
            instrucao->tipo_variavel = no->tipo_dado;
            codigo_atual = intermediario_juntar(codigo_atual, instrucao);
            break;
        }

        default:
            break;
    }

    return codigo_atual;
}

void imprimir_codigo_intermediario(Intermediario *codigo) {
    Intermediario *atual = codigo;
    printf("\n--- CODIGO INTERMEDIARIO ---\n");
    while (atual != NULL) {
        switch (atual->tipo) {
            case INTER_DECLARACAO:
                printf("var %s\n", atual->resultado);
                break;
            case INTER_ATRIBUICAO:
                printf("%s = %s\n", atual->resultado, atual->operador1);
                break;
            case INTER_SOMA:
                printf("%s = %s + %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;
            case INTER_SUBTRACAO:
                printf("%s = %s - %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;
            case INTER_MULTIPLICACAO:
                printf("%s = %s * %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;
            case INTER_DIVISAO:
                printf("%s = %s / %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;
        }
        atual = atual->proximo;
    }
    printf("----------------------------------\n\n");
}