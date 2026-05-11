#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"

// Tabela Hash inicializada com NULL
Simbolo* tabela_hash[HASH_SIZE] = {NULL};

// 1. Cálculo de Hash
unsigned int calcular_hash(const char *nome) { // tem como objetivo pegar o nome do simbolo e calcular em um indice para armazenar
    unsigned int hash = 5381; //semente inicial, pode ser qualquer número, mas 5381 é comumente usado
    int contador;
    while ((contador = *nome++)) { //vai endereçando letra por letra
        hash = hash * 33 + contador;
    } //vai interando letra por letra até ter um número grande
    return hash % HASH_SIZE; //é feito o módulo que será o edereço da variável em nossa tabela
}

