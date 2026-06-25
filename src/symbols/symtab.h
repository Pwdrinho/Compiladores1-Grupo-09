#ifndef TABELA_H
#define TABELA_H

#include <string.h>

#define HASH_SIZE 211 // Tamanho da tabela hash
#define MAX_NAME_LEN 256 // Tamanho máximo para nomes das variáveis, podemos colocar variáveis de até 255 caracteres + '\0'

// Enum para os tipos de dados suportados, temos que ir acrescentando conforme avançamos cada parte do projeto
typedef enum {
    TIPO_DADO_VOID,
    TIPO_DADO_INT,
    TIPO_DADO_FLOAT
} TipoDado;

// Estrutura dos nós da tabela de símbolos
typedef struct Simbolo {

    char nome[MAX_NAME_LEN]; // Nome original da variável, fazemos o calculo com esse nome

    // Esse nome é o que salvamos no código intermediário pra gerar o GO, usamos isso para que nunca haja colisões no GO (ex: "x_0")
    char nome_intermediario[259]; // Tamanho 259: conseguimos no máximo 255 chars do nome + '_' + até 2 dígitos + '\0'

    TipoDado tipo_dado; // enum de tipo de dado (int, float, etc.)

    int escopo; // nível do bloco onde a variável nasceu
    int ativo;  // 1 = visível, 0 = inativada após sair do escopo    

    struct Simbolo *proximo; // tratamento de colisão da Hash, fazemos uma lista encadeada em cada posição da tabela

} Simbolo;

// variável global para ser acessada pelo parser, vai ser incrementada ou decrementada conforme vai passando pelo código
extern int escopo_atual;

// calcula hash de nome na Tabela de Símbolos
unsigned int calcular_hash(const char *nome);

// insere um símbolo na tabela
void inserir_simbolo(const char *nome, TipoDado tipo, int escopo);

// busca mais geral, retorna a variável ativa mais recente com aquele nome
Simbolo* buscar_simbolo(const char *nome);

// busca estrita que olha apenas para um escopo específico, usa em declarações
Simbolo* buscar_simbolo_escopo(const char *nome, int escopo_alvo);

// funções de gerenciamento de escopo
void entrar_escopo(); // aumenta escopo atual
void sair_escopo(); //diminui escopo atual e chama remover_escopo
void remover_escopo(int escopo); // inativa todas as variáveis daquele escopo

#endif