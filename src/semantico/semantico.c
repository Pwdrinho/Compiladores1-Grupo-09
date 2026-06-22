#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "semantico.h"

#define MAX_FUNCOES 128
#define MAX_PARAMETROS 32

/* Assinatura resumida de uma função C do subconjunto.
 * A análise usa esta tabela para permitir chamada antes da definição e validar argumentos.
 */
typedef struct {
    const char *nome;
    TipoDado retorno;
    TipoDado parametros[MAX_PARAMETROS];
    int quantidade_parametros;
    int encontrou_retorno_valor;
} AssinaturaFuncao;

static AssinaturaFuncao funcoes[MAX_FUNCOES];
static int total_funcoes = 0;

/* Converte o enum interno para mensagens de erro mais claras. */
static const char *nome_tipo_dado(TipoDado tipo) {
    switch (tipo) {
        case TIPO_DADO_INT:
            return "int";
        case TIPO_DADO_FLOAT:
            return "float";
        case TIPO_DADO_VOID:
        default:
            return "void";
    }
}

/* A gramática guarda o tipo de retorno como primeiro item da lista da função. */
static TipoDado tipo_retorno_funcao(NoAST *funcao) {
    if (funcao == NULL || funcao->esq == NULL || funcao->esq->esq == NULL) {
        return TIPO_DADO_VOID;
    }

    return funcao->esq->esq->tipo_dado;
}

/* Os parâmetros ficam no segundo item da lista da função. */
static NoAST *parametros_funcao(NoAST *funcao) {
    if (funcao == NULL || funcao->esq == NULL) {
        return NULL;
    }

    return funcao->esq->dir;
}

static AssinaturaFuncao *buscar_funcao(const char *nome) {
    for (int i = 0; i < total_funcoes; i++) {
        if (strcmp(funcoes[i].nome, nome) == 0) {
            return &funcoes[i];
        }
    }

    return NULL;
}

static void adicionar_parametro_assinatura(AssinaturaFuncao *assinatura, TipoDado tipo) {
    if (assinatura->quantidade_parametros >= MAX_PARAMETROS) {
        printf("Erro Semântico: Função '%s' excede o limite de %d parâmetros.\n",
               assinatura->nome, MAX_PARAMETROS);
        exit(1);
    }

    assinatura->parametros[assinatura->quantidade_parametros++] = tipo;
}

/* Percorre a lista binária de parâmetros e registra os tipos na assinatura da função. */
static void coletar_parametros_assinatura(NoAST *no, AssinaturaFuncao *assinatura) {
    if (no == NULL) {
        return;
    }

    if (no->tipo == NO_LISTA) {
        coletar_parametros_assinatura(no->esq, assinatura);
        coletar_parametros_assinatura(no->dir, assinatura);
        return;
    }

    if (no->tipo == NO_PARAMETRO && no->esq != NULL) {
        adicionar_parametro_assinatura(assinatura, no->esq->tipo_dado);
    }
}

/* Registra uma função antes da análise do corpo.
 * Isso permite validar chamadas para funções declaradas mais adiante no arquivo.
 */
static void registrar_funcao(NoAST *funcao) {
    if (funcao == NULL || funcao->valor == NULL) {
        return;
    }

    if (buscar_funcao(funcao->valor) != NULL) {
        printf("Erro Semântico: Função '%s' já declarada.\n", funcao->valor);
        exit(1);
    }

    if (total_funcoes >= MAX_FUNCOES) {
        printf("Erro Semântico: Limite de %d funções excedido.\n", MAX_FUNCOES);
        exit(1);
    }

    AssinaturaFuncao *assinatura = &funcoes[total_funcoes++];
    assinatura->nome = funcao->valor;
    assinatura->retorno = tipo_retorno_funcao(funcao);
    assinatura->quantidade_parametros = 0;
    assinatura->encontrou_retorno_valor = 0;

    coletar_parametros_assinatura(parametros_funcao(funcao), assinatura);
}

/* Primeira passada semântica: coleta todas as assinaturas de funções do programa. */
static void coletar_funcoes(NoAST *no) {
    if (no == NULL) {
        return;
    }

    if (no->tipo == NO_FUNCAO) {
        registrar_funcao(no);
        return;
    }

    coletar_funcoes(no->esq);
    coletar_funcoes(no->dir);
}

/* Argumentos de chamada também são lista binária na AST. */
static int contar_argumentos(NoAST *no) {
    if (no == NULL) {
        return 0;
    }

    if (no->tipo == NO_LISTA) {
        return contar_argumentos(no->esq) + contar_argumentos(no->dir);
    }

    return 1;
}

/* Busca posicional usada para comparar cada argumento recebido com o parâmetro esperado. */
static NoAST *argumento_por_indice(NoAST *no, int *indice_atual, int indice_procurado) {
    if (no == NULL) {
        return NULL;
    }

    if (no->tipo == NO_LISTA) {
        NoAST *encontrado = argumento_por_indice(no->esq, indice_atual, indice_procurado);
        if (encontrado != NULL) {
            return encontrado;
        }

        return argumento_por_indice(no->dir, indice_atual, indice_procurado);
    }

    if (*indice_atual == indice_procurado) {
        return no;
    }

    (*indice_atual)++;
    return NULL;
}

static NoAST *obter_argumento(NoAST *argumentos, int indice) {
    int indice_atual = 0;
    return argumento_por_indice(argumentos, &indice_atual, indice);
}

/* Mantém as conversões simples aceitas no subconjunto e bloqueia usos inválidos de void. */
static void validar_conversao_argumento(const char *nome_funcao,
                                        int posicao,
                                        TipoDado esperado,
                                        TipoDado recebido) {
    if (recebido == TIPO_DADO_VOID) {
        printf("Erro Semântico: Argumento %d da função '%s' não pode ser void.\n",
               posicao + 1, nome_funcao);
        exit(1);
    }

    if (esperado == recebido) {
        return;
    }

    if (esperado == TIPO_DADO_FLOAT && recebido == TIPO_DADO_INT) {
        return;
    }

    if (esperado == TIPO_DADO_INT && recebido == TIPO_DADO_FLOAT) {
        printf("Semântico: Argumento %d da função '%s' converterá float para int.\n",
               posicao + 1, nome_funcao);
        return;
    }

    printf("Erro Semântico: Argumento %d da função '%s' esperava %s, mas recebeu %s.\n",
           posicao + 1,
           nome_funcao,
           nome_tipo_dado(esperado),
           nome_tipo_dado(recebido));
    exit(1);
}

static void analisar_no(NoAST *no, AssinaturaFuncao *funcao_atual);

/* Analisa expressões passadas como argumento antes de conferir a assinatura da chamada. */
static void analisar_lista_argumentos(NoAST *no, AssinaturaFuncao *funcao_atual) {
    if (no == NULL) {
        return;
    }

    if (no->tipo == NO_LISTA) {
        analisar_lista_argumentos(no->esq, funcao_atual);
        analisar_lista_argumentos(no->dir, funcao_atual);
        return;
    }

    analisar_no(no, funcao_atual);
}

/* Valida existência da função, quantidade de argumentos e compatibilidade de tipos. */
static void analisar_chamada_funcao(NoAST *no, AssinaturaFuncao *funcao_atual) {
    analisar_lista_argumentos(no->esq, funcao_atual);

    AssinaturaFuncao *assinatura = buscar_funcao(no->valor);
    if (assinatura == NULL) {
        printf("Erro Semântico: Função '%s' não declarada.\n", no->valor);
        exit(1);
    }

    int quantidade_argumentos = contar_argumentos(no->esq);
    if (quantidade_argumentos != assinatura->quantidade_parametros) {
        printf("Erro Semântico: Função '%s' espera %d argumento(s), mas recebeu %d.\n",
               no->valor,
               assinatura->quantidade_parametros,
               quantidade_argumentos);
        exit(1);
    }

    for (int i = 0; i < quantidade_argumentos; i++) {
        NoAST *argumento = obter_argumento(no->esq, i);
        validar_conversao_argumento(no->valor,
                                    i,
                                    assinatura->parametros[i],
                                    argumento != NULL ? argumento->tipo_dado : TIPO_DADO_VOID);
    }

    no->tipo_dado = assinatura->retorno;
}

/* Garante que o return combina com o tipo declarado da função atual. */
static void validar_retorno(NoAST *no, AssinaturaFuncao *funcao_atual) {
    if (funcao_atual == NULL) {
        return;
    }

    if (no->esq != NULL) {
        analisar_no(no->esq, funcao_atual);
    }

    if (funcao_atual->retorno == TIPO_DADO_VOID) {
        if (no->esq != NULL) {
            printf("Erro Semântico: Função void '%s' não deve retornar valor.\n",
                   funcao_atual->nome);
            exit(1);
        }

        no->tipo_dado = TIPO_DADO_VOID;
        return;
    }

    if (no->esq == NULL) {
        printf("Erro Semântico: Função '%s' deve retornar valor do tipo %s.\n",
               funcao_atual->nome,
               nome_tipo_dado(funcao_atual->retorno));
        exit(1);
    }

    if (funcao_atual->retorno == TIPO_DADO_INT && no->esq->tipo_dado == TIPO_DADO_FLOAT) {
        printf("Semântico: Retorno da função '%s' converterá float para int.\n",
               funcao_atual->nome);
    } else if (funcao_atual->retorno == TIPO_DADO_FLOAT && no->esq->tipo_dado == TIPO_DADO_INT) {
        /* Conversão de int para float é segura no subconjunto atual. */
    } else if (funcao_atual->retorno != no->esq->tipo_dado) {
        printf("Erro Semântico: Função '%s' deve retornar %s, mas retornou %s.\n",
               funcao_atual->nome,
               nome_tipo_dado(funcao_atual->retorno),
               nome_tipo_dado(no->esq->tipo_dado));
        exit(1);
    }

    funcao_atual->encontrou_retorno_valor = 1;
    no->tipo_dado = funcao_atual->retorno;
}

/* Segunda passada semântica: percorre a AST atribuindo tipos e validando usos. */
static void analisar_no(NoAST *no, AssinaturaFuncao *funcao_atual) {
    if (no == NULL) {
        return;
    }

    switch (no->tipo) {
        case NO_PROGRAMA:
        case NO_LISTA:
        case NO_BLOCO:
            analisar_no(no->esq, funcao_atual);
            analisar_no(no->dir, funcao_atual);
            break;

        case NO_FUNCAO: {
            AssinaturaFuncao *assinatura = buscar_funcao(no->valor);
            analisar_no(no->esq, assinatura);
            analisar_no(no->dir, assinatura);
            no->tipo_dado = assinatura != NULL ? assinatura->retorno : TIPO_DADO_VOID;

            if (assinatura != NULL &&
                assinatura->retorno != TIPO_DADO_VOID &&
                !assinatura->encontrou_retorno_valor) {
                printf("Erro Semântico: Função '%s' deve retornar valor do tipo %s.\n",
                       assinatura->nome,
                       nome_tipo_dado(assinatura->retorno));
                exit(1);
            }
            break;
        }

        case NO_PARAMETRO:
            analisar_no(no->esq, funcao_atual);
            if (no->esq != NULL) {
                no->tipo_dado = no->esq->tipo_dado;
            }
            break;

        case NO_TIPO:
            break;

        case NO_NUMERO:
            if (strchr(no->valor, '.') != NULL) {
                no->tipo_dado = TIPO_DADO_FLOAT;
            } else {
                no->tipo_dado = TIPO_DADO_INT;
            }
            break;

        case NO_IDENTIFICADOR:
            if (no->simbolo != NULL) {
                no->tipo_dado = no->simbolo->tipo_dado;
            }
            break;

        case NO_CHAMADA_FUNCAO:
            analisar_chamada_funcao(no, funcao_atual);
            break;

        case NO_DECLARACAO:
            analisar_no(no->esq, funcao_atual);
            analisar_no(no->dir, funcao_atual);
            if (no->esq != NULL) {
                no->tipo_dado = no->esq->tipo_dado;
            }
            break;

        case NO_ATRIBUICAO:
            analisar_no(no->esq, funcao_atual);
            analisar_no(no->dir, funcao_atual);
            if (no->esq != NULL && no->dir != NULL) {
                TipoDado tipo_dest = no->esq->tipo_dado;
                TipoDado tipo_origem = no->dir->tipo_dado;

                if (tipo_origem == TIPO_DADO_VOID) {
                    printf("Erro Semântico: Atribuição de valor void para '%s'.\n",
                           no->esq->valor);
                    exit(1);
                }

                if (tipo_dest == TIPO_DADO_INT && tipo_origem == TIPO_DADO_FLOAT) {
                    printf("Semântico: Atribuição de float para int na variável '%s' causará truncamento.\n",
                           no->esq->valor);
                }

                no->tipo_dado = tipo_dest;
            }
            break;

        case NO_RETORNO:
            validar_retorno(no, funcao_atual);
            break;

        case NO_BINARIO:
            analisar_no(no->esq, funcao_atual);
            analisar_no(no->dir, funcao_atual);
            if (no->esq != NULL && no->dir != NULL) {
                if (no->esq->tipo_dado == TIPO_DADO_VOID || no->dir->tipo_dado == TIPO_DADO_VOID) {
                    printf("Erro Semântico: Operador '%s' não aceita operando void.\n", no->valor);
                    exit(1);
                }

                if (strcmp(no->valor, "/") == 0 &&
                    no->dir->tipo == NO_NUMERO &&
                    strcmp(no->dir->valor, "0") == 0) {
                    printf("Erro Semântico: Divisão literal por zero detectada!\n");
                    exit(1);
                }

                if (no->esq->tipo_dado == TIPO_DADO_FLOAT || no->dir->tipo_dado == TIPO_DADO_FLOAT) {
                    no->tipo_dado = TIPO_DADO_FLOAT;
                } else {
                    no->tipo_dado = TIPO_DADO_INT;
                }
            }
            break;

        case NO_UNARIO:
            analisar_no(no->esq, funcao_atual);
            if (no->esq != NULL) {
                no->tipo_dado = no->esq->tipo_dado;
            }
            break;

        case NO_ACESSO_VETOR:
            analisar_no(no->esq, funcao_atual);
            if (no->simbolo != NULL) {
                no->tipo_dado = no->simbolo->tipo_dado;
            }
            break;

        case NO_IF:
        case NO_WHILE:
        case NO_FOR:
        default:
            analisar_no(no->esq, funcao_atual);
            analisar_no(no->dir, funcao_atual);
            break;
    }
}

/* Ponto de entrada da semântica: coleta assinaturas e depois valida o programa. */
void analisar_semantica(NoAST *no) {
    total_funcoes = 0;
    coletar_funcoes(no);
    analisar_no(no, NULL);
}
