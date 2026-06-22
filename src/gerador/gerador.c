#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "gerador.h"

/* Gerador antigo baseado no código intermediário.
 * Mantido para comparação e depuração; a entrega principal usa gerar_codigo_go_ast.
 */
void gerar_codigo_go(Intermediario *primeiro, const char *nome_arquivo) {
    FILE *arquivo = fopen(nome_arquivo, "w");
    if (arquivo == NULL) {
        printf("Erro fatal: Não foi possível criar o arquivo de saída '%s'\n", nome_arquivo);
        return;
    }

    fprintf(arquivo, "package main\n\n");
    fprintf(arquivo, "import \"fmt\"\n\n");
    fprintf(arquivo, "func main() {\n");

    Intermediario *atual = primeiro;
    while (atual != NULL) {
        fprintf(arquivo, "    ");

        switch (atual->tipo) {
            case INTER_DECLARACAO:
                // Escreve o tipo correto lido da tabela de símbolos
                if (atual->tipo_variavel == TIPO_DADO_INT) {
                    fprintf(arquivo, "var %s int\n", atual->resultado);
                } else if (atual->tipo_variavel == TIPO_DADO_FLOAT) {
                    fprintf(arquivo, "var %s float64\n", atual->resultado);
                } else {
                    fprintf(arquivo, "var %s interface{}\n", atual->resultado);
                }
                break;

            case INTER_ATRIBUICAO:
                // Força o "cast" explícito no Go para imitar a coerção do C
                if (atual->tipo_variavel == TIPO_DADO_INT) {
                    fprintf(arquivo, "%s = int(%s)\n", atual->resultado, atual->operador1);
                } else if (atual->tipo_variavel == TIPO_DADO_FLOAT) {
                    fprintf(arquivo, "%s = float64(%s)\n", atual->resultado, atual->operador1);
                } else {
                    fprintf(arquivo, "%s = %s\n", atual->resultado, atual->operador1);
                }
                break;

            case INTER_SOMA:
                fprintf(arquivo, "%s := %s + %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;

            case INTER_SUBTRACAO:
                fprintf(arquivo, "%s := %s - %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;

            case INTER_MULTIPLICACAO:
                fprintf(arquivo, "%s := %s * %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;

            case INTER_DIVISAO:
                fprintf(arquivo, "%s := %s / %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;
        }
        
        atual = atual->proximo;
    }

    fprintf(arquivo, "\n    // Comando para evitar que o Go reclame de pacotes não usados\n");
    fprintf(arquivo, "    fmt.Println(\"Programa compilado e executado com sucesso!\")\n");
    
    fprintf(arquivo, "}\n");
    fclose(arquivo);

    printf("--> Sucesso! Arquivo alvo '%s' gerado.\n", nome_arquivo);
}

/* As funções de expressão retornam strings alocadas dinamicamente.
 * Estes helpers centralizam cópia/formatação e encerram o compilador em falha de memória.
 */
static char *duplicar_texto(const char *texto) {
    if (texto == NULL) {
        texto = "";
    }

    char *copia = malloc(strlen(texto) + 1);
    if (copia == NULL) {
        printf("Erro fatal: Falha de memória no gerador Go.\n");
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
        printf("Erro fatal: Falha ao formatar texto no gerador Go.\n");
        exit(1);
    }

    char *texto = malloc((size_t)tamanho + 1);
    if (texto == NULL) {
        printf("Erro fatal: Falha de memória no gerador Go.\n");
        exit(1);
    }

    va_start(args, formato);
    vsnprintf(texto, (size_t)tamanho + 1, formato, args);
    va_end(args);

    return texto;
}

static void imprimir_indentacao(FILE *arquivo, int nivel) {
    for (int i = 0; i < nivel; i++) {
        fprintf(arquivo, "    ");
    }
}

static const char *tipo_go(TipoDado tipo) {
    switch (tipo) {
        case TIPO_DADO_INT:
            return "int";
        case TIPO_DADO_FLOAT:
            return "float64";
        case TIPO_DADO_VOID:
        default:
            return "";
    }
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

static char *gerar_expressao_go(NoAST *no);
static void gerar_comando_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main);
static void gerar_conteudo_bloco_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main);

/* A AST representa listas como árvore binária. Esta função lineariza os argumentos
 * preservando a ordem original para chamadas como soma(2, 3).
 */
static char *gerar_argumentos_go(NoAST *no) {
    if (no == NULL) {
        return duplicar_texto("");
    }

    if (no->tipo == NO_LISTA) {
        char *esq = gerar_argumentos_go(no->esq);
        char *dir = gerar_argumentos_go(no->dir);
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

    return gerar_expressao_go(no);
}

static int main_usa_fmt(NoAST *no, int dentro_main) {
    if (no == NULL) {
        return 0;
    }

    if (no->tipo == NO_FUNCAO) {
        dentro_main = (no->valor != NULL && strcmp(no->valor, "main") == 0);
    }

    if (dentro_main && no->tipo == NO_RETORNO && no->esq != NULL) {
        return 1;
    }

    return main_usa_fmt(no->esq, dentro_main) || main_usa_fmt(no->dir, dentro_main);
}

/* Traduz expressões C simples para expressões Go.
 * O retorno sempre pertence ao chamador e deve ser liberado com free.
 */
static char *gerar_expressao_go(NoAST *no) {
    if (no == NULL) {
        return duplicar_texto("");
    }

    switch (no->tipo) {
        case NO_NUMERO:
        case NO_IDENTIFICADOR:
            return duplicar_texto(nome_no(no));

        case NO_ACESSO_VETOR: {
            char *indice = gerar_expressao_go(no->esq);
            char *resultado = formatar_texto("%s[%s]", nome_no(no), indice);
            free(indice);
            return resultado;
        }

        case NO_BINARIO: {
            char *esq = gerar_expressao_go(no->esq);
            char *dir = gerar_expressao_go(no->dir);
            char *resultado = formatar_texto("(%s %s %s)", esq, nome_no(no), dir);
            free(esq);
            free(dir);
            return resultado;
        }

        case NO_CHAMADA_FUNCAO: {
            char *argumentos = gerar_argumentos_go(no->esq);
            char *resultado = formatar_texto("%s(%s)", nome_no(no), argumentos);
            free(argumentos);
            return resultado;
        }

        default:
            return duplicar_texto(nome_no(no));
    }
}

/* Gera comandos usados dentro do cabeçalho de for, onde o Go não aceita quebra de linha. */
static char *gerar_comando_inline_go(NoAST *no) {
    if (no == NULL) {
        return duplicar_texto("");
    }

    switch (no->tipo) {
        case NO_DECLARACAO: {
            const char *nome = nome_no(no);

            if (no->dir != NULL && no->dir->tipo == NO_ATRIBUICAO) {
                char *valor = gerar_expressao_go(no->dir->dir);
                char *resultado = formatar_texto("%s := %s", nome, valor);
                free(valor);
                return resultado;
            }

            return formatar_texto("%s := 0", nome);
        }

        case NO_ATRIBUICAO: {
            char *destino = gerar_expressao_go(no->esq);
            char *valor = gerar_expressao_go(no->dir);
            char *resultado = formatar_texto("%s %s %s", destino, nome_no(no), valor);
            free(destino);
            free(valor);
            return resultado;
        }

        case NO_UNARIO: {
            char *identificador = gerar_expressao_go(no->esq);
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
            return gerar_expressao_go(no);
    }
}

static void gerar_declaracao_go(FILE *arquivo, NoAST *no, int indentacao) {
    const char *nome = nome_no(no);
    const char *tipo = tipo_go(no->tipo_dado);

    imprimir_indentacao(arquivo, indentacao);

    if (no->dir != NULL && no->dir->tipo == NO_ATRIBUICAO) {
        char *valor = gerar_expressao_go(no->dir->dir);
        fprintf(arquivo, "var %s %s = %s\n", nome, tipo, valor);
        free(valor);
        return;
    }

    if (no->dir != NULL && no->dir->tipo == NO_NUMERO) {
        fprintf(arquivo, "var %s [%s]%s\n", nome, nome_no(no->dir), tipo);
        return;
    }

    fprintf(arquivo, "var %s %s\n", nome, tipo);
}

static void gerar_atribuicao_go(FILE *arquivo, NoAST *no, int indentacao) {
    char *destino = gerar_expressao_go(no->esq);
    char *valor = gerar_expressao_go(no->dir);

    imprimir_indentacao(arquivo, indentacao);
    fprintf(arquivo, "%s %s %s\n", destino, nome_no(no), valor);

    free(destino);
    free(valor);
}

static void gerar_retorno_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main) {
    imprimir_indentacao(arquivo, indentacao);

    if (no->esq == NULL) {
        fprintf(arquivo, "return\n");
        return;
    }

    char *valor = gerar_expressao_go(no->esq);

    if (dentro_main) {
        // Go não permite retorno de valor em main; imprimimos o valor para preservar a demonstração.
        fprintf(arquivo, "fmt.Println(%s)\n", valor);
        imprimir_indentacao(arquivo, indentacao);
        fprintf(arquivo, "return\n");
    } else {
        fprintf(arquivo, "return %s\n", valor);
    }

    free(valor);
}

/* O parser marca if/else com valor "if_else"; por isso o bloco then/else é separado aqui. */
static void gerar_if_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main) {
    char *condicao = gerar_expressao_go(no->esq);
    NoAST *bloco_if = no->dir;
    NoAST *bloco_else = NULL;

    if (no->valor != NULL && strcmp(no->valor, "if_else") == 0 && no->dir != NULL) {
        bloco_if = no->dir->esq;
        bloco_else = no->dir->dir;
    }

    imprimir_indentacao(arquivo, indentacao);
    fprintf(arquivo, "if %s {\n", condicao);
    gerar_conteudo_bloco_go(arquivo, bloco_if, indentacao + 1, dentro_main);
    imprimir_indentacao(arquivo, indentacao);

    if (bloco_else != NULL) {
        fprintf(arquivo, "} else {\n");
        gerar_conteudo_bloco_go(arquivo, bloco_else, indentacao + 1, dentro_main);
        imprimir_indentacao(arquivo, indentacao);
        fprintf(arquivo, "}\n");
    } else {
        fprintf(arquivo, "}\n");
    }

    free(condicao);
}

static void gerar_while_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main) {
    char *condicao = gerar_expressao_go(no->esq);

    imprimir_indentacao(arquivo, indentacao);
    fprintf(arquivo, "for %s {\n", condicao);
    gerar_conteudo_bloco_go(arquivo, no->dir, indentacao + 1, dentro_main);
    imprimir_indentacao(arquivo, indentacao);
    fprintf(arquivo, "}\n");

    free(condicao);
}

/* O for da AST guarda inicialização/condição/atualização em subárvores.
 * Aqui essas partes são extraídas para emitir o cabeçalho Go equivalente.
 */
static void gerar_for_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main) {
    NoAST *cabecalho = no->esq;
    NoAST *cabecalho_parcial = cabecalho != NULL ? cabecalho->esq : NULL;
    NoAST *inicializacao = cabecalho_parcial != NULL ? cabecalho_parcial->esq : NULL;
    NoAST *condicao_no = cabecalho_parcial != NULL ? cabecalho_parcial->dir : NULL;
    NoAST *atualizacao = cabecalho != NULL ? cabecalho->dir : NULL;

    char *inicializacao_txt = gerar_comando_inline_go(inicializacao);
    char *condicao_txt = gerar_expressao_go(condicao_no);
    char *atualizacao_txt = gerar_comando_inline_go(atualizacao);

    imprimir_indentacao(arquivo, indentacao);

    if (strlen(inicializacao_txt) == 0 && strlen(atualizacao_txt) == 0) {
        if (strlen(condicao_txt) == 0) {
            fprintf(arquivo, "for {\n");
        } else {
            fprintf(arquivo, "for %s {\n", condicao_txt);
        }
    } else {
        fprintf(arquivo, "for %s; %s; %s {\n", inicializacao_txt, condicao_txt, atualizacao_txt);
    }

    gerar_conteudo_bloco_go(arquivo, no->dir, indentacao + 1, dentro_main);
    imprimir_indentacao(arquivo, indentacao);
    fprintf(arquivo, "}\n");

    free(inicializacao_txt);
    free(condicao_txt);
    free(atualizacao_txt);
}

static void gerar_unario_go(FILE *arquivo, NoAST *no, int indentacao) {
    char *comando = gerar_comando_inline_go(no);

    imprimir_indentacao(arquivo, indentacao);
    fprintf(arquivo, "%s\n", comando);

    free(comando);
}

/* Ponto central de emissão de comandos. Cada tipo de nó delega para um gerador específico. */
static void gerar_comando_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main) {
    if (no == NULL) {
        return;
    }

    switch (no->tipo) {
        case NO_LISTA:
            gerar_comando_go(arquivo, no->esq, indentacao, dentro_main);
            gerar_comando_go(arquivo, no->dir, indentacao, dentro_main);
            break;

        case NO_BLOCO:
            imprimir_indentacao(arquivo, indentacao);
            fprintf(arquivo, "{\n");
            gerar_conteudo_bloco_go(arquivo, no, indentacao + 1, dentro_main);
            imprimir_indentacao(arquivo, indentacao);
            fprintf(arquivo, "}\n");
            break;

        case NO_DECLARACAO:
            gerar_declaracao_go(arquivo, no, indentacao);
            break;

        case NO_ATRIBUICAO:
            gerar_atribuicao_go(arquivo, no, indentacao);
            break;

        case NO_RETORNO:
            gerar_retorno_go(arquivo, no, indentacao, dentro_main);
            break;

        case NO_IF:
            gerar_if_go(arquivo, no, indentacao, dentro_main);
            break;

        case NO_WHILE:
            gerar_while_go(arquivo, no, indentacao, dentro_main);
            break;

        case NO_FOR:
            gerar_for_go(arquivo, no, indentacao, dentro_main);
            break;

        case NO_UNARIO:
            gerar_unario_go(arquivo, no, indentacao);
            break;

        case NO_CHAMADA_FUNCAO: {
            char *chamada = gerar_expressao_go(no);
            imprimir_indentacao(arquivo, indentacao);
            fprintf(arquivo, "%s\n", chamada);
            free(chamada);
            break;
        }

        default:
            break;
    }
}

static void gerar_conteudo_bloco_go(FILE *arquivo, NoAST *no, int indentacao, int dentro_main) {
    if (no == NULL) {
        return;
    }

    if (no->tipo == NO_BLOCO) {
        gerar_comando_go(arquivo, no->esq, indentacao, dentro_main);
    } else {
        gerar_comando_go(arquivo, no, indentacao, dentro_main);
    }
}

/* Parâmetros também chegam como lista binária, então são impressos recursivamente
 * com controle explícito da vírgula entre eles.
 */
static void gerar_parametros_go(FILE *arquivo, NoAST *no, int *primeiro) {
    if (no == NULL) {
        return;
    }

    if (no->tipo == NO_LISTA) {
        gerar_parametros_go(arquivo, no->esq, primeiro);
        gerar_parametros_go(arquivo, no->dir, primeiro);
        return;
    }

    if (no->tipo == NO_PARAMETRO) {
        if (!*primeiro) {
            fprintf(arquivo, ", ");
        }

        fprintf(arquivo, "%s %s", nome_no(no), tipo_go(no->esq->tipo_dado));
        *primeiro = 0;
    }
}

static TipoDado tipo_retorno_funcao(NoAST *funcao) {
    if (funcao == NULL || funcao->esq == NULL || funcao->esq->esq == NULL) {
        return TIPO_DADO_VOID;
    }

    return funcao->esq->esq->tipo_dado;
}

/* Em Go, main não recebe retorno. As demais funções preservam o tipo inferido da AST. */
static void gerar_funcao_go(FILE *arquivo, NoAST *funcao) {
    int eh_main = (funcao->valor != NULL && strcmp(funcao->valor, "main") == 0);
    NoAST *parametros = (funcao->esq != NULL) ? funcao->esq->dir : NULL;
    TipoDado retorno = tipo_retorno_funcao(funcao);

    if (eh_main) {
        fprintf(arquivo, "func main() {\n");
    } else {
        int primeiro = 1;
        fprintf(arquivo, "func %s(", nome_no(funcao));
        gerar_parametros_go(arquivo, parametros, &primeiro);
        fprintf(arquivo, ")");

        if (retorno != TIPO_DADO_VOID) {
            fprintf(arquivo, " %s", tipo_go(retorno));
        }

        fprintf(arquivo, " {\n");
    }

    gerar_conteudo_bloco_go(arquivo, funcao->dir, 1, eh_main);
    fprintf(arquivo, "}\n\n");
}

/* Percorre somente declarações globais e funções, que são os elementos válidos no topo do Go. */
static void gerar_top_level_go(FILE *arquivo, NoAST *no) {
    if (no == NULL) {
        return;
    }

    switch (no->tipo) {
        case NO_PROGRAMA:
            gerar_top_level_go(arquivo, no->esq);
            break;

        case NO_LISTA:
            gerar_top_level_go(arquivo, no->esq);
            gerar_top_level_go(arquivo, no->dir);
            break;

        case NO_FUNCAO:
            gerar_funcao_go(arquivo, no);
            break;

        case NO_DECLARACAO:
            gerar_declaracao_go(arquivo, no, 0);
            fprintf(arquivo, "\n");
            break;

        default:
            break;
    }
}

/* Entrada principal da geração final: cria o arquivo Go a partir da AST já validada. */
void gerar_codigo_go_ast(NoAST *raiz, const char *nome_arquivo) {
    FILE *arquivo = fopen(nome_arquivo, "w");
    if (arquivo == NULL) {
        printf("Erro fatal: Não foi possível criar o arquivo de saída '%s'\n", nome_arquivo);
        return;
    }

    int usa_fmt = main_usa_fmt(raiz, 0);

    fprintf(arquivo, "package main\n\n");
    if (usa_fmt) {
        fprintf(arquivo, "import \"fmt\"\n\n");
    }

    gerar_top_level_go(arquivo, raiz);

    fclose(arquivo);

    printf("--> Código Go final gerado em '%s'.\n", nome_arquivo);
}
