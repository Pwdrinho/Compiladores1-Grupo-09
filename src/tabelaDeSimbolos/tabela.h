#ifndef TABELA_H
#define TABELA_H

#include <string.h>

// Tamanho primo - recomendação do monitor CHAT kkk - também representa o tamanho máximo da nossa tabela HASH
#define HASH_SIZE 211 
#define MAX_NAME_LEN 32

// Estrutura do nó da Tabela Hash
typedef struct Simbolo {
    char nome[MAX_NAME_LEN];
    char *tipo; //tipo de variável (int, float, etc.)
    int escopo; //nível que está no código
    int ativo; // 1 = visível para busca e inserção, 0 = removido do escopo - usaremos pra deixar mais rápido
    struct Simbolo *proximo;
} Simbolo;

// Funções
unsigned int calcular_hash(const char *nome);
void inserir_simbolo(const char *nome, char *tipo, int escopo);
Simbolo* buscar_simbolo(const char *nome);
void remover_escopo(int escopo);

#endif