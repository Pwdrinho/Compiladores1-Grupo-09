#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "intermediario.h"

// Contador global oculto para gerar temporários (t0, t1, t2...).
// Mantido para compatibilidade com a primeira versão do intermediário.
static int contador_temporarios = 0;

static char *duplicar_texto(const char *texto) {
    if (texto == NULL) {
        texto = "";
    }

    char *copia = malloc(strlen(texto) + 1);
    if (copia == NULL) {
        printf("Erro fatal: Falha de memória no código intermediário.\n");
        exit(1);
    }

    strcpy(copia, texto);
    return copia;
}

static char *formatar_texto(const char *formato, ...) {
    va_list args;
    va_start(args, formato);
    int tamanho = vsnprintf(NULL, 0, formato, args);
    va_end(args);

    if (tamanho < 0) {
        printf("Erro fatal: Falha ao formatar código intermediário.\n");
        exit(1);
    }

    char *texto = malloc((size_t)tamanho + 1);
    if (texto == NULL) {
        printf("Erro fatal: Falha de memória no código intermediário.\n");
        exit(1);
    }

    va_start(args, formato);
    vsnprintf(texto, (size_t)tamanho + 1, formato, args);
    va_end(args);

    return texto;
}

static const char *nome_no(NoAST *no) {
    if (no == NULL) {
        return "";
    }

    if (no->valor != NULL) {
        return no->valor;
    }

    if (no->simbolo != NULL) {
        return no->simbolo->nome;
    }

    return "";
}

static const char *nome_tipo(TipoDado tipo) {
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

static TipoDado tipo_retorno_funcao(NoAST *funcao) {
    if (funcao == NULL || funcao->esq == NULL || funcao->esq->esq == NULL) {
        return TIPO_DADO_VOID;
    }

    return funcao->esq->esq->tipo_dado;
}

// A regra de função monta o cabeçalho como NO_LISTA(tipo_retorno, parametros).
static NoAST *parametros_funcao(NoAST *funcao) {
    if (funcao == NULL || funcao->esq == NULL) {
        return NULL;
    }

    return funcao->esq->dir;
}

char* criar_temp() {
    char buffer[32];
    snprintf(buffer, sizeof(buffer), "t%d", contador_temporarios++);
    return duplicar_texto(buffer);
}

// Cria uma instrução intermediária.
Intermediario* intermediario_criar(TipoIntermediario tipo, const char *res, const char *op1, const char *op2) {
    Intermediario *inst = malloc(sizeof(Intermediario));
    if (inst == NULL) {
        printf("Erro fatal: Falha de memória ao criar instrução intermediária.\n");
        exit(1);
    }

    inst->tipo = tipo;
    inst->resultado = res ? duplicar_texto(res) : NULL;
    inst->operador1 = op1 ? duplicar_texto(op1) : NULL;
    inst->operador2 = op2 ? duplicar_texto(op2) : NULL;
    inst->tipo_variavel = TIPO_DADO_VOID;
    inst->anterior = NULL;
    inst->proximo = NULL;
    return inst;
}

static Intermediario *intermediario_criar_tipado(TipoIntermediario tipo,
                                                 const char *res,
                                                 const char *op1,
                                                 const char *op2,
                                                 TipoDado tipo_variavel) {
    Intermediario *inst = intermediario_criar(tipo, res, op1, op2);
    inst->tipo_variavel = tipo_variavel;
    return inst;
}

// Une duas listas de instruções.
Intermediario* intermediario_juntar(Intermediario *l1, Intermediario *l2) {
    if (l1 == NULL) return l2;
    if (l2 == NULL) return l1;

    Intermediario *atual = l1;
    while (atual->proximo != NULL) {
        atual = atual->proximo;
    }

    atual->proximo = l2;
    l2->anterior = atual;

    return l1;
}

static char *gerar_expressao_intermediaria(NoAST *no);

// A AST guarda listas como uma árvore binária. Aqui a lista vira "a, b, c".
static char *gerar_argumentos_intermediarios(NoAST *no) {
    if (no == NULL) {
        return duplicar_texto("");
    }

    if (no->tipo == NO_LISTA) {
        char *esq = gerar_argumentos_intermediarios(no->esq);
        char *dir = gerar_argumentos_intermediarios(no->dir);
        char *resultado = NULL;

        if (strlen(esq) == 0) {
            resultado = duplicar_texto(dir);
        } else if (strlen(dir) == 0) {
            resultado = duplicar_texto(esq);
        } else {
            resultado = formatar_texto("%s, %s", esq, dir);
        }

        free(esq);
        free(dir);
        return resultado;
    }

    return gerar_expressao_intermediaria(no);
}

static char *gerar_expressao_intermediaria(NoAST *no) {
    if (no == NULL) {
        return duplicar_texto("");
    }

    switch (no->tipo) {
        case NO_NUMERO:
        case NO_IDENTIFICADOR:
            return duplicar_texto(nome_no(no));

        case NO_ACESSO_VETOR: {
            char *indice = gerar_expressao_intermediaria(no->esq);
            char *resultado = formatar_texto("%s[%s]", nome_no(no), indice);
            free(indice);
            return resultado;
        }

        case NO_BINARIO: {
            // No IR estruturado mantemos a expressão textual, pois o alvo Go
            // preserva bem expressões infixas simples do subconjunto.
            char *esq = gerar_expressao_intermediaria(no->esq);
            char *dir = gerar_expressao_intermediaria(no->dir);
            char *resultado = formatar_texto("(%s %s %s)", esq, nome_no(no), dir);
            free(esq);
            free(dir);
            return resultado;
        }

        case NO_CHAMADA_FUNCAO: {
            char *argumentos = gerar_argumentos_intermediarios(no->esq);
            char *resultado = formatar_texto("%s(%s)", nome_no(no), argumentos);
            free(argumentos);
            return resultado;
        }

        default:
            return duplicar_texto(nome_no(no));
    }
}

// Usado no cabeçalho do for, onde o comando precisa estar em uma única linha.
static char *gerar_comando_inline_intermediario(NoAST *no) {
    if (no == NULL) {
        return duplicar_texto("");
    }

    switch (no->tipo) {
        case NO_DECLARACAO: {
            const char *nome = nome_no(no);

            if (no->dir != NULL && no->dir->tipo == NO_ATRIBUICAO) {
                char *valor = gerar_expressao_intermediaria(no->dir->dir);
                char *resultado = formatar_texto("%s := %s", nome, valor);
                free(valor);
                return resultado;
            }

            return formatar_texto("%s := 0", nome);
        }

        case NO_ATRIBUICAO: {
            char *destino = gerar_expressao_intermediaria(no->esq);
            char *valor = gerar_expressao_intermediaria(no->dir);
            char *resultado = formatar_texto("%s %s %s", destino, nome_no(no), valor);
            free(destino);
            free(valor);
            return resultado;
        }

        case NO_UNARIO: {
            char *identificador = gerar_expressao_intermediaria(no->esq);
            const char *operador = nome_no(no);
            char *resultado = NULL;

            if (strncmp(operador, "--", 2) == 0) {
                resultado = formatar_texto("%s--", identificador);
            } else {
                resultado = formatar_texto("%s++", identificador);
            }

            free(identificador);
            return resultado;
        }

        default:
            return gerar_expressao_intermediaria(no);
    }
}

static Intermediario *gerar_parametros(NoAST *no) {
    if (no == NULL) {
        return NULL;
    }

    if (no->tipo == NO_LISTA) {
        return intermediario_juntar(gerar_parametros(no->esq), gerar_parametros(no->dir));
    }

    if (no->tipo == NO_PARAMETRO) {
        TipoDado tipo = no->esq != NULL ? no->esq->tipo_dado : no->tipo_dado;
        return intermediario_criar_tipado(INTER_PARAMETRO, nome_no(no), NULL, NULL, tipo);
    }

    return NULL;
}

static Intermediario *gerar_no(NoAST *no);

static Intermediario *gerar_declaracao(NoAST *no) {
    const char *nome = nome_no(no);

    if (no->dir != NULL && no->dir->tipo == NO_ATRIBUICAO) {
        // Declaração com inicialização vira uma única instrução do IR.
        char *valor = gerar_expressao_intermediaria(no->dir->dir);
        Intermediario *inst = intermediario_criar_tipado(INTER_DECLARACAO,
                                                         nome,
                                                         valor,
                                                         NULL,
                                                         no->tipo_dado);
        free(valor);
        return inst;
    }

    if (no->dir != NULL && no->dir->tipo == NO_NUMERO) {
        // Em declaração de vetor, operador2 guarda o tamanho para o gerador Go.
        return intermediario_criar_tipado(INTER_DECLARACAO,
                                          nome,
                                          NULL,
                                          nome_no(no->dir),
                                          no->tipo_dado);
    }

    return intermediario_criar_tipado(INTER_DECLARACAO, nome, NULL, NULL, no->tipo_dado);
}

static Intermediario *gerar_atribuicao(NoAST *no) {
    char *destino = gerar_expressao_intermediaria(no->esq);
    char *valor = gerar_expressao_intermediaria(no->dir);
    Intermediario *inst = intermediario_criar_tipado(INTER_ATRIBUICAO,
                                                     destino,
                                                     valor,
                                                     nome_no(no),
                                                     no->tipo_dado);
    free(destino);
    free(valor);
    return inst;
}

static Intermediario *gerar_if(NoAST *no) {
    char *condicao = gerar_expressao_intermediaria(no->esq);
    Intermediario *inicio = intermediario_criar(INTER_IF_INICIO, NULL, condicao, NULL);
    free(condicao);

    if (no->valor != NULL && strcmp(no->valor, "if_else") == 0 && no->dir != NULL) {
        // O parser guarda then/else dentro de uma lista; aqui linearizamos
        // como IF, bloco then, ELSE, bloco else, ENDIF.
        Intermediario *bloco_if = gerar_no(no->dir->esq);
        Intermediario *separador_else = intermediario_criar(INTER_ELSE_INICIO, NULL, NULL, NULL);
        Intermediario *bloco_else = gerar_no(no->dir->dir);
        Intermediario *fim = intermediario_criar(INTER_IF_FIM, NULL, NULL, NULL);

        return intermediario_juntar(intermediario_juntar(intermediario_juntar(intermediario_juntar(inicio, bloco_if),
                                                                              separador_else),
                                                         bloco_else),
                                    fim);
    }

    return intermediario_juntar(intermediario_juntar(inicio, gerar_no(no->dir)),
                                intermediario_criar(INTER_IF_FIM, NULL, NULL, NULL));
}

static Intermediario *gerar_while(NoAST *no) {
    char *condicao = gerar_expressao_intermediaria(no->esq);
    Intermediario *inicio = intermediario_criar(INTER_WHILE_INICIO, NULL, condicao, NULL);
    free(condicao);

    return intermediario_juntar(intermediario_juntar(inicio, gerar_no(no->dir)),
                                intermediario_criar(INTER_WHILE_FIM, NULL, NULL, NULL));
}

static Intermediario *gerar_for(NoAST *no) {
    // O cabeçalho do for fica em duas listas aninhadas:
    // ((inicialização, condição), atualização).
    NoAST *cabecalho = no->esq;
    NoAST *cabecalho_parcial = cabecalho != NULL ? cabecalho->esq : NULL;
    NoAST *inicializacao = cabecalho_parcial != NULL ? cabecalho_parcial->esq : NULL;
    NoAST *condicao = cabecalho_parcial != NULL ? cabecalho_parcial->dir : NULL;
    NoAST *atualizacao = cabecalho != NULL ? cabecalho->dir : NULL;

    char *inicializacao_txt = gerar_comando_inline_intermediario(inicializacao);
    char *condicao_txt = gerar_expressao_intermediaria(condicao);
    char *atualizacao_txt = gerar_comando_inline_intermediario(atualizacao);

    Intermediario *inicio = intermediario_criar(INTER_FOR_INICIO,
                                                inicializacao_txt,
                                                condicao_txt,
                                                atualizacao_txt);

    free(inicializacao_txt);
    free(condicao_txt);
    free(atualizacao_txt);

    return intermediario_juntar(intermediario_juntar(inicio, gerar_no(no->dir)),
                                intermediario_criar(INTER_FOR_FIM, NULL, NULL, NULL));
}

static Intermediario *gerar_no(NoAST *no) {
    if (no == NULL) {
        return NULL;
    }

    switch (no->tipo) {
        case NO_PROGRAMA:
        case NO_BLOCO:
            return gerar_no(no->esq);

        case NO_LISTA:
            // Listas da AST são árvores binárias; no IR viram uma lista linear.
            return intermediario_juntar(gerar_no(no->esq), gerar_no(no->dir));

        case NO_FUNCAO: {
            TipoDado retorno = tipo_retorno_funcao(no);
            Intermediario *inicio = intermediario_criar_tipado(INTER_FUNCAO_INICIO,
                                                               nome_no(no),
                                                               NULL,
                                                               NULL,
                                                               retorno);
            Intermediario *parametros = gerar_parametros(parametros_funcao(no));
            Intermediario *corpo = gerar_no(no->dir);
            Intermediario *fim = intermediario_criar(INTER_FUNCAO_FIM, nome_no(no), NULL, NULL);

            // Funções são delimitadas explicitamente para o gerador final
            // saber onde começa e termina cada assinatura/corpo.
            return intermediario_juntar(intermediario_juntar(intermediario_juntar(inicio, parametros),
                                                             corpo),
                                        fim);
        }

        case NO_DECLARACAO:
            return gerar_declaracao(no);

        case NO_ATRIBUICAO:
            return gerar_atribuicao(no);

        case NO_RETORNO: {
            char *valor = no->esq != NULL ? gerar_expressao_intermediaria(no->esq) : NULL;
            Intermediario *inst = intermediario_criar_tipado(INTER_RETORNO,
                                                             NULL,
                                                             valor,
                                                             NULL,
                                                             no->tipo_dado);
            free(valor);
            return inst;
        }

        case NO_IF:
            return gerar_if(no);

        case NO_WHILE:
            return gerar_while(no);

        case NO_FOR:
            return gerar_for(no);

        case NO_UNARIO: {
            char *expr = gerar_comando_inline_intermediario(no);
            Intermediario *inst = intermediario_criar(INTER_EXPRESSAO, expr, NULL, NULL);
            free(expr);
            return inst;
        }

        case NO_CHAMADA_FUNCAO: {
            char *chamada = gerar_expressao_intermediaria(no);
            Intermediario *inst = intermediario_criar_tipado(INTER_CHAMADA_FUNCAO,
                                                             chamada,
                                                             NULL,
                                                             NULL,
                                                             no->tipo_dado);
            free(chamada);
            return inst;
        }

        default:
            return NULL;
    }
}

Intermediario* gerar_codigo_intermediario(NoAST *no) {
    // Reinicia temporários para manter a saída determinística entre execuções.
    contador_temporarios = 0;
    return gerar_no(no);
}

void imprimir_codigo_intermediario(Intermediario *codigo) {
    Intermediario *atual = codigo;
    printf("\n--- CODIGO INTERMEDIARIO ---\n");
    while (atual != NULL) {
        switch (atual->tipo) {
            case INTER_FUNCAO_INICIO:
                printf("func %s %s\n", atual->resultado, nome_tipo(atual->tipo_variavel));
                break;
            case INTER_FUNCAO_FIM:
                printf("endfunc\n");
                break;
            case INTER_PARAMETRO:
                printf("param %s %s\n", atual->resultado, nome_tipo(atual->tipo_variavel));
                break;
            case INTER_DECLARACAO:
                if (atual->operador2 != NULL) {
                    printf("decl %s [%s]%s\n",
                           atual->resultado,
                           atual->operador2,
                           nome_tipo(atual->tipo_variavel));
                } else if (atual->operador1 != NULL) {
                    printf("decl %s %s = %s\n",
                           atual->resultado,
                           nome_tipo(atual->tipo_variavel),
                           atual->operador1);
                } else {
                    printf("decl %s %s\n", atual->resultado, nome_tipo(atual->tipo_variavel));
                }
                break;
            case INTER_ATRIBUICAO:
                printf("assign %s %s %s\n",
                       atual->resultado,
                       atual->operador2 != NULL ? atual->operador2 : "=",
                       atual->operador1 != NULL ? atual->operador1 : "");
                break;
            case INTER_RETORNO:
                if (atual->operador1 != NULL) {
                    printf("return %s\n", atual->operador1);
                } else {
                    printf("return\n");
                }
                break;
            case INTER_IF_INICIO:
                printf("if %s\n", atual->operador1);
                break;
            case INTER_ELSE_INICIO:
                printf("else\n");
                break;
            case INTER_IF_FIM:
                printf("endif\n");
                break;
            case INTER_WHILE_INICIO:
                printf("while %s\n", atual->operador1);
                break;
            case INTER_WHILE_FIM:
                printf("endwhile\n");
                break;
            case INTER_FOR_INICIO:
                printf("for %s; %s; %s\n",
                       atual->resultado != NULL ? atual->resultado : "",
                       atual->operador1 != NULL ? atual->operador1 : "",
                       atual->operador2 != NULL ? atual->operador2 : "");
                break;
            case INTER_FOR_FIM:
                printf("endfor\n");
                break;
            case INTER_CHAMADA_FUNCAO:
                printf("call %s\n", atual->resultado);
                break;
            case INTER_EXPRESSAO:
                printf("expr %s\n", atual->resultado);
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

void liberar_codigo_intermediario(Intermediario *codigo) {
    while (codigo != NULL) {
        Intermediario *proximo = codigo->proximo;
        free(codigo->resultado);
        free(codigo->operador1);
        free(codigo->operador2);
        free(codigo);
        codigo = proximo;
    }
}
