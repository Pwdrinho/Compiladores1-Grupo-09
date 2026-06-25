#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

Simbolo* tabela_hash[HASH_SIZE] = {NULL};

// inicializa escopo global com 0
int escopo_atual = 0;

// contador: usamos apenas para gerar IDs únicos para os nomes dos intermediários.
static int contador_variaveis_globais = 0; 

// calculo de hash para posição na tabela
unsigned int calcular_hash(const char *nome) { 
    unsigned int hash = 5381; // recomendação do monitor chatGPT
    int contador;
    while ((contador = *nome++)) { // lê letra por letra
        hash = hash * 33 + contador;
    } 
    return hash % HASH_SIZE;  // faz o modulo para saber o indice na tabela
}

// inserir elemento na tabela
void inserir_simbolo(const char *nome, TipoDado tipo, int escopo) {
    unsigned int indice = calcular_hash(nome); // calcula o hash e acha o indice
    
    Simbolo *novo_simbolo = (Simbolo*) malloc(sizeof(Simbolo)); // aloca espaço na memoria para o novo simbolo
    
    if (novo_simbolo == NULL) { // verifica se a alocação foi bem sucedida
        printf("Erro: Falha na alocação de memória para o símbolo.\n");
        exit(1);
    }

    // salva o nome original
    strncpy(novo_simbolo->nome, nome, MAX_NAME_LEN - 1); // Copia o nome com segurança, evitando buffer overflow
    novo_simbolo->nome[MAX_NAME_LEN - 1] = '\0'; 
    
    // salva o nome intermediário (ex: "x_0", "x_1", etc.) 
    snprintf(novo_simbolo->nome_intermediario, 259, "%s_%d", nome, contador_variaveis_globais++);

    novo_simbolo->tipo_dado = tipo;
    novo_simbolo->escopo = escopo;
    novo_simbolo->ativo = 1; 

    // insere no inicio da lista encadeada daquele índice
    novo_simbolo->proximo = tabela_hash[indice];
    tabela_hash[indice] = novo_simbolo;
}

// busca geral, pega a variável ativa mais recente com aquele nome - usamos para chamar variaveis, em contas x = y + z por exemplo
Simbolo* buscar_simbolo(const char *nome) {
    unsigned int indice = calcular_hash(nome); 
    Simbolo *atual = tabela_hash[indice];

    while (atual != NULL) {
        // retorna a primeira ocorrencia ativa
        if (strcmp(atual->nome, nome) == 0 && atual->ativo == 1) { // strcmp(atual->nome, nome) == 0 verifica se as strings são iguais vendo endereço na memoria
            return atual;
        }
        atual = atual->proximo;
    }
    return NULL; // se não achar, a variável não existe ou não está ativa
}

// busca mais detalhada, vamos olhar na declaração pra ver se já existe alguma variavel com mesmo nome
Simbolo* buscar_simbolo_escopo(const char *nome, int escopo_alvo) {
    unsigned int indice = calcular_hash(nome); 
    Simbolo *atual = tabela_hash[indice];

    while (atual != NULL) {
        if (strcmp(atual->nome, nome) == 0 && atual->ativo == 1 && atual->escopo == escopo_alvo) {
            return atual;
        }
        atual = atual->proximo;
    }
    return NULL; // Se não achar no escopo atual, está livre para ser declarada
}

void entrar_escopo() {
    escopo_atual++;
}

void sair_escopo() {

    // Inativa todas as variáveis do escopo que estamos fechando
    remover_escopo(escopo_atual);

    escopo_atual--;
}

// deixa inativo todas as variaveis daquele escopo
void remover_escopo(int escopo) {
    for (int i = 0; i < HASH_SIZE; i++) { 
        Simbolo *atual = tabela_hash[i];
        while (atual != NULL) { 
            if (atual->escopo == escopo && atual->ativo == 1) { 
                atual->ativo = 0;
            }
            atual = atual->proximo;
        }
    }
}