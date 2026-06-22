#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "semantico.h"

void analisar_semantica(NoAST *no) {
    // condição de parada da recursão
    if (no == NULL) {
        return;
    }

    // recursão
    analisar_semantica(no->esq);
    analisar_semantica(no->dir);

    // avaliação do nó atual
    switch (no->tipo) {
        
        case NO_NUMERO:
            // se tiver o ponto no numero é um float, se não é um int... não é o ideal mas no momento é o melhor pro nosso escopo
            if (strchr(no->valor, '.') != NULL) {
                no->tipo_dado = TIPO_DADO_FLOAT;
            } else {
                no->tipo_dado = TIPO_DADO_INT;
            }
            break;

        case NO_IDENTIFICADOR:
            // o tipo de dado vem da tabela de símbolos
            if (no->simbolo != NULL) {
                no->tipo_dado = no->simbolo->tipo_dado;
            }
            break;

        case NO_CHAMADA_FUNCAO:
            // No subconjunto atual assumimos retorno int para chamadas simples.
            no->tipo_dado = TIPO_DADO_INT;
            break;

        case NO_DECLARACAO:
            // o tipo da declaração é herdado do filho esquerdo que é o NO_TIPO
            if (no->esq != NULL) {
                no->tipo_dado = no->esq->tipo_dado;
            }
            break;

        case NO_ATRIBUICAO:
            // o filho esquerdo é onde vamos salvar o que atribuimos e o direito é o valor que vamos colocar
            if (no->esq != NULL && no->dir != NULL) {
                TipoDado tipo_dest = no->esq->tipo_dado;
                TipoDado tipo_origem = no->dir->tipo_dado;

                // vamos avisar pro usuario se ele colocar um float em um int
                if (tipo_dest == TIPO_DADO_INT && tipo_origem == TIPO_DADO_FLOAT) {
                    printf("Semântico: Atribuição de float para int na variável '%s' causará truncamento.\n", no->esq->valor);
                }

                // O nó de atribuição sempre assume o tipo da variável destino
                no->tipo_dado = tipo_dest;
            }
            break;

        case NO_BINARIO:
            // Lida com as operações: +, -, *, / e outras lógicas
            if (no->esq != NULL && no->dir != NULL) {
                
                // Validação: Divisão por Zero Literal
                if (strcmp(no->valor, "/") == 0) {
                    if (no->dir->tipo == NO_NUMERO && strcmp(no->dir->valor, "0") == 0) {
                        printf("Erro Semântico: Divisão literal por zero detectada!\n");
                        exit(1); // Erro fatal
                    }
                }

                // Aplicação da Coerção de Tipos
                TipoDado tipo_esq = no->esq->tipo_dado;
                TipoDado tipo_dir = no->dir->tipo_dado;

                // Se houver um float envolvido, o resultado sobe para float
                if (tipo_esq == TIPO_DADO_FLOAT || tipo_dir == TIPO_DADO_FLOAT) {
                    no->tipo_dado = TIPO_DADO_FLOAT;
                } else {
                    no->tipo_dado = TIPO_DADO_INT; // Caso contrário, fica int
                }
            }
            break;

        default:
            //printf("Semântico: Tipo de nó não tratado.\n");
            break;
    }
}
