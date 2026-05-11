#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"

// Tabela Hash inicializada com NULL
Simbolo* tabela_hash[HASH_SIZE] = {NULL};

// Cálculo de Hash
unsigned int calcular_hash(const char *nome) { // tem como objetivo pegar o nome do simbolo e calcular em um indice para armazenar
    unsigned int hash = 5381; //semente inicial, pode ser qualquer número, mas 5381 é comumente usado
    int contador;
    while ((contador = *nome++)) { //vai endereçando letra por letra
        hash = hash * 33 + contador;
    } //vai interando letra por letra até ter um número grande
    return hash % HASH_SIZE; //é feito o módulo que será o edereço da variável em nossa tabela
}

// Inserção
void inserir_simbolo(const char *nome, char *tipo, int escopo) {
    unsigned int indice = calcular_hash(nome); //endereço onde o simbolo deve ser inserido
    
    // Criação do novo símbolo
    Simbolo *novo_simbolo = (Simbolo*) malloc(sizeof(Simbolo)); //aloca uma memoria para o novo simbolo
    if (novo_simbolo == NULL) {
        printf("Erro: Falha na alocação de memória para o símbolo.\n");
        return;
    }

    strncpy(novo_simbolo->nome, nome, MAX_NAME_LEN - 1); // copia o nome, mas garante que não passe de 32 letras
    novo_simbolo->nome[MAX_NAME_LEN - 1] = '\0'; // Garante terminação nula
    novo_simbolo->tipo = tipo;
    novo_simbolo->escopo = escopo;
    novo_simbolo->ativo = 1; // Símbolo ativo ao ser criado

    // Insere no início da lista encadeada (tratamento de colisão)
    novo_simbolo->proximo = tabela_hash[indice];
    tabela_hash[indice] = novo_simbolo;
}

