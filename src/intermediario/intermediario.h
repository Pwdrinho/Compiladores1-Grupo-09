#ifndef INTERMEDIARIO_H
#define INTERMEDIARIO_H

#include "../ast/ast.h"

// enum mapeando os tipos de instruções suportadas, vamos acrescentando conforme avançamos no projeto
typedef enum {
    INTER_DECLARACAO,
    INTER_ATRIBUICAO,
    INTER_SOMA,
    INTER_SUBTRACAO,
    INTER_MULTIPLICACAO,
    INTER_DIVISAO
} TipoIntermediario;

// estrutura do código de três endereços, estilo assambly
typedef struct Intermediario {
    TipoIntermediario tipo;
    char *resultado;  // destino
    char *operador1;  // origem 1
    char *operador2;  // origem 2 (usamos em operações binárias, em atribuições fica NULL)
    TipoDado tipo_variavel;
    struct Intermediario *anterior;
    struct Intermediario *proximo;
} Intermediario;

// funções principais
Intermediario* gerar_codigo_intermediario(NoAST *no);
void imprimir_codigo_intermediario(Intermediario *codigo);

// funções utilitárias
Intermediario* intermediario_criar(TipoIntermediario tipo, const char *res, const char *op1, const char *op2);
Intermediario* intermediario_juntar(Intermediario *l1, Intermediario *l2);
char* criar_temp();

#endif