#ifndef GERADOR_H
#define GERADOR_H

#include "../intermediario/intermediario.h"

void gerar_codigo_go(Intermediario *primeiro, const char *nome_arquivo);
void gerar_codigo_go_ast(NoAST *raiz, const char *nome_arquivo);

#endif
