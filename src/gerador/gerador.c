#include <stdio.h>
#include <string.h>
#include "gerador.h"

static const char *tipo_go_ir(TipoDado tipo) {
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

static int texto_vazio(const char *texto) {
    return texto == NULL || strlen(texto) == 0;
}

static void imprimir_indentacao_ir(FILE *arquivo, int nivel) {
    for (int i = 0; i < nivel; i++) {
        fprintf(arquivo, "    ");
    }
}

static int intermediario_main_usa_fmt(Intermediario *codigo) {
    int dentro_main = 0;

    // Só importamos fmt quando a main tem return com valor,
    // pois esse valor precisa virar impressão em Go.
    for (Intermediario *atual = codigo; atual != NULL; atual = atual->proximo) {
        if (atual->tipo == INTER_FUNCAO_INICIO) {
            dentro_main = (atual->resultado != NULL && strcmp(atual->resultado, "main") == 0);
        } else if (atual->tipo == INTER_FUNCAO_FIM) {
            dentro_main = 0;
        } else if (dentro_main && atual->tipo == INTER_RETORNO && !texto_vazio(atual->operador1)) {
            return 1;
        }
    }

    return 0;
}

static void gerar_assinatura_funcao_ir(FILE *arquivo, Intermediario *funcao, int eh_main) {
    if (eh_main) {
        // Go exige func main() sem parâmetros e sem retorno.
        fprintf(arquivo, "func main() {\n");
        return;
    }

    fprintf(arquivo, "func %s(", funcao->resultado);

    int primeiro = 1;
    // Os parâmetros aparecem imediatamente após INTER_FUNCAO_INICIO no IR.
    for (Intermediario *param = funcao->proximo;
         param != NULL && param->tipo == INTER_PARAMETRO;
         param = param->proximo) {
        if (!primeiro) {
            fprintf(arquivo, ", ");
        }

        fprintf(arquivo, "%s %s", param->resultado, tipo_go_ir(param->tipo_variavel));
        primeiro = 0;
    }

    fprintf(arquivo, ")");
    if (funcao->tipo_variavel != TIPO_DADO_VOID) {
        fprintf(arquivo, " %s", tipo_go_ir(funcao->tipo_variavel));
    }

    fprintf(arquivo, " {\n");
}

/* Geração final baseada no código intermediário estruturado.
 * Este é o caminho principal da entrega: AST -> IR -> Go.
 */
void gerar_codigo_go(Intermediario *primeiro, const char *nome_arquivo) {
    FILE *arquivo = fopen(nome_arquivo, "w");
    if (arquivo == NULL) {
        printf("Erro fatal: Não foi possível criar o arquivo de saída '%s'\n", nome_arquivo);
        return;
    }

    fprintf(arquivo, "package main\n\n");
    if (intermediario_main_usa_fmt(primeiro)) {
        fprintf(arquivo, "import \"fmt\"\n\n");
    }

    int indentacao = 0;
    int dentro_main = 0;

    // O IR já está em ordem de execução/declaração; o gerador só traduz cada
    // instrução para a forma sintática equivalente em Go.
    for (Intermediario *atual = primeiro; atual != NULL; atual = atual->proximo) {
        switch (atual->tipo) {
            case INTER_FUNCAO_INICIO: {
                dentro_main = (atual->resultado != NULL && strcmp(atual->resultado, "main") == 0);
                gerar_assinatura_funcao_ir(arquivo, atual, dentro_main);
                indentacao = 1;

                // Os parâmetros já foram consumidos ao montar a assinatura.
                while (atual->proximo != NULL && atual->proximo->tipo == INTER_PARAMETRO) {
                    atual = atual->proximo;
                }
                break;
            }

            case INTER_FUNCAO_FIM:
                indentacao = 0;
                dentro_main = 0;
                fprintf(arquivo, "}\n\n");
                break;

            case INTER_PARAMETRO:
                break;

            case INTER_DECLARACAO:
                imprimir_indentacao_ir(arquivo, indentacao);
                if (!texto_vazio(atual->operador2)) {
                    fprintf(arquivo, "var %s [%s]%s\n",
                            atual->resultado,
                            atual->operador2,
                            tipo_go_ir(atual->tipo_variavel));
                } else if (!texto_vazio(atual->operador1)) {
                    fprintf(arquivo, "var %s %s = %s\n",
                            atual->resultado,
                            tipo_go_ir(atual->tipo_variavel),
                            atual->operador1);
                } else {
                    fprintf(arquivo, "var %s %s\n", atual->resultado, tipo_go_ir(atual->tipo_variavel));
                }
                break;

            case INTER_ATRIBUICAO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "%s %s %s\n",
                        atual->resultado,
                        !texto_vazio(atual->operador2) ? atual->operador2 : "=",
                        atual->operador1 != NULL ? atual->operador1 : "");
                break;

            case INTER_RETORNO:
                imprimir_indentacao_ir(arquivo, indentacao);
                if (texto_vazio(atual->operador1)) {
                    fprintf(arquivo, "return\n");
                } else if (dentro_main) {
                    // C permite "return valor" na main; em Go demonstramos o
                    // resultado imprimindo o valor e encerrando a função.
                    fprintf(arquivo, "fmt.Println(%s)\n", atual->operador1);
                    imprimir_indentacao_ir(arquivo, indentacao);
                    fprintf(arquivo, "return\n");
                } else {
                    fprintf(arquivo, "return %s\n", atual->operador1);
                }
                break;

            case INTER_IF_INICIO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "if %s {\n", atual->operador1);
                indentacao++;
                break;

            case INTER_ELSE_INICIO:
                // O else fecha o bloco anterior e abre outro no mesmo nível.
                indentacao--;
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "} else {\n");
                indentacao++;
                break;

            case INTER_IF_FIM:
                indentacao--;
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "}\n");
                break;

            case INTER_WHILE_INICIO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "for %s {\n", atual->operador1);
                indentacao++;
                break;

            case INTER_WHILE_FIM:
                indentacao--;
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "}\n");
                break;

            case INTER_FOR_INICIO:
                imprimir_indentacao_ir(arquivo, indentacao);
                // Um while sem inicialização/atualização também é representado
                // como for em Go, igual à sintaxe idiomática da linguagem.
                if (texto_vazio(atual->resultado) && texto_vazio(atual->operador2)) {
                    if (texto_vazio(atual->operador1)) {
                        fprintf(arquivo, "for {\n");
                    } else {
                        fprintf(arquivo, "for %s {\n", atual->operador1);
                    }
                } else {
                    fprintf(arquivo, "for %s; %s; %s {\n",
                            atual->resultado != NULL ? atual->resultado : "",
                            atual->operador1 != NULL ? atual->operador1 : "",
                            atual->operador2 != NULL ? atual->operador2 : "");
                }
                indentacao++;
                break;

            case INTER_FOR_FIM:
                indentacao--;
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "}\n");
                break;

            case INTER_CHAMADA_FUNCAO:
            case INTER_EXPRESSAO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "%s\n", atual->resultado);
                break;

            case INTER_SOMA:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "%s := %s + %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;

            case INTER_SUBTRACAO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "%s := %s - %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;

            case INTER_MULTIPLICACAO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "%s := %s * %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;

            case INTER_DIVISAO:
                imprimir_indentacao_ir(arquivo, indentacao);
                fprintf(arquivo, "%s := %s / %s\n", atual->resultado, atual->operador1, atual->operador2);
                break;
        }
    }

    fclose(arquivo);

    printf("--> Código Go final gerado em '%s'.\n", nome_arquivo);
}
