#ifndef INTERMEDIARIO_H
#define INTERMEDIARIO_H

#include "../ast/ast.h"

// Enum do IR estruturado. Em vez de guardar apenas temporários, ele preserva
// a estrutura necessária para reconstruir funções, blocos e comandos em Go.
typedef enum {
    INTER_FUNCAO_INICIO,
    INTER_FUNCAO_FIM,
    INTER_PARAMETRO,
    INTER_DECLARACAO,
    INTER_ATRIBUICAO,
    INTER_RETORNO,
    INTER_IF_INICIO,
    INTER_ELSE_INICIO,
    INTER_IF_FIM,
    INTER_WHILE_INICIO,
    INTER_WHILE_FIM,
    INTER_FOR_INICIO,
    INTER_FOR_FIM,
    INTER_CHAMADA_FUNCAO,
    INTER_EXPRESSAO,

    // Operações aritméticas mantidas para compatibilidade com a versão inicial do IR.
    INTER_SOMA,
    INTER_SUBTRACAO,
    INTER_MULTIPLICACAO,
    INTER_DIVISAO
} TipoIntermediario;

// Estrutura linear do código intermediário.
// O significado dos campos depende do tipo da instrução. Exemplos:
// - INTER_FUNCAO_INICIO: resultado=nome, tipo_variavel=tipo de retorno
// - INTER_DECLARACAO: resultado=variável, operador1=valor inicial opcional
// - INTER_ATRIBUICAO: resultado=destino, operador1=expressão, operador2=operador
// - INTER_RETORNO: operador1=expressão retornada, quando existir
// - INTER_IF_INICIO/INTER_WHILE_INICIO: operador1=condição
// - INTER_FOR_INICIO: resultado=inicialização, operador1=condição, operador2=atualização
typedef struct Intermediario {
    TipoIntermediario tipo;
    char *resultado;
    char *operador1;
    char *operador2;
    TipoDado tipo_variavel;
    struct Intermediario *anterior;
    struct Intermediario *proximo;
} Intermediario;

// funções principais
Intermediario* gerar_codigo_intermediario(NoAST *no);
void imprimir_codigo_intermediario(Intermediario *codigo);
void liberar_codigo_intermediario(Intermediario *codigo);

// funções utilitárias
Intermediario* intermediario_criar(TipoIntermediario tipo, const char *res, const char *op1, const char *op2);
Intermediario* intermediario_juntar(Intermediario *l1, Intermediario *l2);
char* criar_temp();

#endif
