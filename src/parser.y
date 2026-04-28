%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

/* Palavras reservadas */
%token 

/* Identificadores e números */
%token

/* Operadores */
%token

/* Delimitadores */
%token

%%

programa:
      lista_funcoes
;

lista_funcoes:
      lista_funcoes funcao
    | funcao
;

funcao:
      tipo IDENT TK_ABRE_PARENTESE TK_FECHA_PARENTESE bloco
;

tipo:
      KW_INT
    | KW_FLOAT
    | KW_VOID
;

bloco:
      TK_ABRE_CHAVE lista_comandos TK_FECHA_CHAVE
;

lista_comandos:
      lista_comandos comando
    | /* vazio */
;

comando:
      declaracao
    | atribuicao
    | retorno
    | comando_if
    | comando_while
;

declaracao:
      tipo IDENT TK_OP_PONTO_VIRGULA
    | tipo IDENT TK_OP_IGUAL expressao TK_OP_PONTO_VIRGULA
;

atribuicao:
      IDENT TK_OP_IGUAL expressao TK_OP_PONTO_VIRGULA
;

retorno:
      KW_RETURN expressao TK_OP_PONTO_VIRGULA
;

comando_if:
      KW_IF TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco
    | KW_IF TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco KW_ELSE bloco
;

comando_while:
      KW_WHILE TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco
;

expressao_booleana:
      expressao operador_relacional expressao
;

operador_relacional:
      TK_OP_MENOR
    | TK_OP_MAIOR
    | TK_OP_MENOR_IGUAL
    | TK_OP_MAIOR_IGUAL
    | TK_OP_IGUAL_COMPARACAO
    | TK_OP_DIFERENTE
;

expressao:
      expressao TK_OP_SOMA termo
    | expressao TK_OP_SUBTRACAO termo
    | termo
;

termo:
      termo TK_OP_MULTIPLICACAO fator
    | termo TK_OP_DIVISAO fator
    | fator
;

fator:
      NUMBER
    | IDENT
    | TK_ABRE_PARENTESE expressao TK_FECHA_PARENTESE
;

%%

void yyerror(const char *s) {
    printf("Erro sintático: %s\n", s);
}

int main(void) {
    return yyparse();
}