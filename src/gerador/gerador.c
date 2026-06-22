#include <stdio.h>
#include <stdlib.h>
#include "gerador.h"

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