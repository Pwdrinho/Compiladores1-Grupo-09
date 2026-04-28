%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
%}

/* Palavras reservadas */
%token KW_AUTO
%token KW_BREAK
%token KW_CASE
%token KW_CHAR
%token KW_CONST
%token KW_CONTINUE
%token KW_DEFAULT
%token KW_DO
%token KW_DOUBLE
%token KW_ELSE
%token KW_ENUM
%token KW_EXTERN
%token KW_FLOAT
%token KW_FOR
%token KW_GOTO
%token KW_IF
%token KW_INT
%token KW_LONG
%token KW_REGISTER
%token KW_RETURN
%token KW_SHORT
%token KW_SIGNED
%token KW_SIZEOF
%token KW_STATIC
%token KW_STRUCT
%token KW_SWITCH
%token KW_TYPEDEF
%token KW_UNION
%token KW_UNSIGNED
%token KW_VOID
%token KW_VOLATILE
%token KW_WHILE

/* Identificadores e números */
%token IDENT
%token NUMBER

/* Operadores compostos */
%token TK_OP_IGUAL_COMPARACAO
%token TK_OP_DIFERENTE
%token TK_OP_MENOR_IGUAL
%token TK_OP_MAIOR_IGUAL
%token TK_OP_AND
%token TK_OP_OR
%token TK_OP_INCREMENTO
%token TK_OP_DECREMENTO
%token TK_OP_MAIS_IGUAL
%token TK_OP_MENOS_IGUAL
%token TK_OP_MULTIPLICACAO_IGUAL
%token TK_OP_DIVISAO_IGUAL
%token TK_OP_MODULO_IGUAL
%token TK_OP_DESLOCAMENTO_ESQUERDA
%token TK_OP_DESLOCAMENTO_DIREITA
%token TK_OP_PONTEIRO_ACESSO

/* Operadores simples */
%token TK_OP_SOMA
%token TK_OP_SUBTRACAO
%token TK_OP_MULTIPLICACAO
%token TK_OP_DIVISAO
%token TK_OP_MODULO
%token TK_OP_IGUAL
%token TK_OP_MENOR
%token TK_OP_MAIOR
%token TK_OP_NAO
%token TK_OP_E_BIT
%token TK_OP_OU_BIT
%token TK_OP_XOR_BIT
%token TK_OP_NOT_BIT
%token TK_OP_TERNARIO
%token TK_OP_DOIS_PONTOS
%token TK_OP_PONTO
%token TK_OP_VIRGULA
%token TK_OP_PONTO_VIRGULA

/* Delimitadores */
%token TK_ABRE_PARENTESE
%token TK_FECHA_PARENTESE
%token TK_ABRE_CHAVE
%token TK_FECHA_CHAVE
%token TK_ABRE_COLCHETE
%token TK_FECHA_COLCHETE

/* Precedência */
%left TK_OP_OR
%left TK_OP_AND
%left TK_OP_IGUAL_COMPARACAO TK_OP_DIFERENTE
%left TK_OP_MENOR TK_OP_MAIOR TK_OP_MENOR_IGUAL TK_OP_MAIOR_IGUAL
%left TK_OP_SOMA TK_OP_SUBTRACAO
%left TK_OP_MULTIPLICACAO TK_OP_DIVISAO TK_OP_MODULO
%right TK_OP_NAO
%right TK_OP_IGUAL
%nonassoc LOWER_THAN_ELSE
%nonassoc KW_ELSE

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