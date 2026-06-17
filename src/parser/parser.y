%code requires {
    #include "ast.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "symtab.h"

/*
 * Função gerada pelo Flex.
 * O parser chama yylex() sempre que precisa do próximo token.
 */
int yylex(void);

/*
 * Função chamada pelo Bison quando encontra erro sintático.
 */
void yyerror(const char *s);

/*
 * Ponteiro global para guardar a raiz da árvore sintática.
 * No final do parsing, essa variável apontará para o nó NO_PROGRAMA.
 */
NoAST *raiz_ast = NULL;
%}

%union {
    char *str;
    NoAST *no;
}

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
%token <str> IDENT
%token <str> NUMBER

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

/*
 * Regras que produzem nós da AST.
 * Cada regra declarada com <no> usa $$, $1, $2 etc. como NoAST*.
 */
%type <no> programa
%type <no> lista_funcoes funcao
%type <no> parametros lista_parametros parametro
%type <no> tipo bloco lista_comandos comando
%type <no> declaracao atribuicao incremento retorno
%type <no> comando_if comando_while comando_for
%type <no> for_init for_condicao for_atualizacao
%type <no> declaracao_for atribuicao_for incremento_for
%type <no> expressao_booleana expressao termo fator acesso_vetor

/* operador_relacional devolve o símbolo textual do operador: <, >, <=, >=, == ou != */
%type <str> operador_relacional

%%

programa:
      lista_funcoes
      {
        /*
         * Raiz da AST.
         * Tudo que foi reconhecido no programa fica abaixo de NO_PROGRAMA.
         */
        raiz_ast = criar_no(NO_PROGRAMA, $1, NULL, NULL);
        $$ = raiz_ast;

        printf("Análise sintática concluída\n");
        imprimir_ast(raiz_ast, 0);
      }
;

lista_funcoes:
      lista_funcoes funcao
      {
        /* Encadeia múltiplas funções em uma lista binária. */
        $$ = criar_no(NO_LISTA, $1, $2, NULL);
      }
    | funcao
      {
        $$ = $1;
      }
;

funcao:
      tipo IDENT TK_ABRE_PARENTESE parametros TK_FECHA_PARENTESE bloco
      {
        /*
         * Função:
         * valor -> nome da função
         * esq   -> lista contendo tipo e parâmetros
         * dir   -> bloco da função
         */
        NoAST *cabecalho = criar_no(NO_LISTA, $1, $4, NULL);
        $$ = criar_no(NO_FUNCAO, cabecalho, $6, $2);
        free($2);
      }
;

parametros:
      lista_parametros
      {
        $$ = $1;
      }
    | /* vazio */
      {
        $$ = NULL;
      }
;

lista_parametros:
      lista_parametros TK_OP_VIRGULA parametro
      {
        $$ = criar_no(NO_LISTA, $1, $3, NULL);
      }
    | parametro
      {
        $$ = $1;
      }
;

parametro:
      tipo IDENT
      {
        /*
         * Parâmetro de função.
         * Exemplo: int x
         */
        $$ = criar_no(NO_PARAMETRO, $1, NULL, $2);
        free($2);
      }
;

tipo:
      KW_INT
      {
        $$ = criar_no(NO_TIPO, NULL, NULL, "int");
      }
    | KW_FLOAT
      {
        $$ = criar_no(NO_TIPO, NULL, NULL, "float");
      }
    | KW_VOID
      {
        $$ = criar_no(NO_TIPO, NULL, NULL, "void");
      }
;

bloco:
      TK_ABRE_CHAVE lista_comandos TK_FECHA_CHAVE
      {
        $$ = criar_no(NO_BLOCO, $2, NULL, NULL);
      }
;

lista_comandos:
      lista_comandos comando
      {
        $$ = criar_no(NO_LISTA, $1, $2, NULL);
      }
    | /* vazio */
      {
        $$ = NULL;
      }
;

comando:
      declaracao
      {
        $$ = $1;
      }
    | atribuicao
      {
        $$ = $1;
      }
    | retorno
      {
        $$ = $1;
      }
    | comando_if
      {
        $$ = $1;
      }
    | comando_while
      {
        $$ = $1;
      }
    | comando_for
      {
        $$ = $1;
      }
    | incremento
      {
        $$ = $1;
      }
    | bloco
      {
        $$ = $1;
      }
;

declaracao:
      tipo IDENT TK_OP_PONTO_VIRGULA
      {
        /*
         * Declaração simples.
         * Exemplo: int x;
         */
        $$ = criar_no(NO_DECLARACAO, $1, NULL, $2);
        free($2);
      }
    | tipo IDENT TK_OP_IGUAL expressao TK_OP_PONTO_VIRGULA
      {
        /*
         * Declaração com inicialização.
         * Exemplo: int x = 10 + 2;
         */
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2);
        NoAST *atribuicao_inicial = criar_no(NO_ATRIBUICAO, id, $4, "=");
        $$ = criar_no(NO_DECLARACAO, $1, atribuicao_inicial, $2);
        free($2);
      }
    | tipo IDENT TK_ABRE_COLCHETE NUMBER TK_FECHA_COLCHETE TK_OP_PONTO_VIRGULA
      {
        /*
         * Declaração de vetor.
         * Exemplo: int v[10];
         */
        NoAST *tamanho = criar_no(NO_NUMERO, NULL, NULL, $4);
        $$ = criar_no(NO_DECLARACAO, $1, tamanho, $2);
        free($2);
        free($4);
      }
;

atribuicao:
      IDENT TK_OP_IGUAL expressao TK_OP_PONTO_VIRGULA
      {
        /*
         * Atribuição simples.
         * Exemplo: x = 10 + 2;
         */
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "=");
        free($1);
      }
;

incremento:
      IDENT TK_OP_INCREMENTO TK_OP_PONTO_VIRGULA
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pos");
        free($1);
      }
    | IDENT TK_OP_DECREMENTO TK_OP_PONTO_VIRGULA
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pos");
        free($1);
      }
    | TK_OP_INCREMENTO IDENT TK_OP_PONTO_VIRGULA
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pre");
        free($2);
      }
    | TK_OP_DECREMENTO IDENT TK_OP_PONTO_VIRGULA
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pre");
        free($2);
      }
;

retorno:
      KW_RETURN expressao TK_OP_PONTO_VIRGULA
      {
        $$ = criar_no(NO_RETORNO, $2, NULL, NULL);
      }
    | KW_RETURN TK_OP_PONTO_VIRGULA
      {
        $$ = criar_no(NO_RETORNO, NULL, NULL, NULL);
      }
;

comando_if:
      KW_IF TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco %prec LOWER_THAN_ELSE
      {
        /*
         * If sem else.
         * esq -> condição
         * dir -> bloco do if
         */
        $$ = criar_no(NO_IF, $3, $5, "if");
      }
    | KW_IF TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco KW_ELSE bloco
      {
        /*
         * If com else.
         * esq -> condição
         * dir -> lista contendo bloco do if e bloco do else
         */
        NoAST *blocos = criar_no(NO_LISTA, $5, $7, NULL);
        $$ = criar_no(NO_IF, $3, blocos, "if_else");
      }
;

comando_while:
      KW_WHILE TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco
      {
        /*
         * While.
         * esq -> condição
         * dir -> bloco repetido
         */
        $$ = criar_no(NO_WHILE, $3, $5, NULL);
      }
;

comando_for:
      KW_FOR TK_ABRE_PARENTESE for_init TK_OP_PONTO_VIRGULA for_condicao TK_OP_PONTO_VIRGULA for_atualizacao TK_FECHA_PARENTESE bloco
      {
        /*
         * For.
         * Como a AST é binária, agrupamos init, condição e atualização em listas.
         */
        NoAST *cabecalho_parcial = criar_no(NO_LISTA, $3, $5, NULL);
        NoAST *cabecalho = criar_no(NO_LISTA, cabecalho_parcial, $7, NULL);
        $$ = criar_no(NO_FOR, cabecalho, $9, NULL);
      }
;

for_init:
      declaracao_for
      {
        $$ = $1;
      }
    | atribuicao_for
      {
        $$ = $1;
      }
    | /* vazio */
      {
        $$ = NULL;
      }
;

for_condicao:
      expressao_booleana
      {
        $$ = $1;
      }
    | /* vazio */
      {
        $$ = NULL;
      }
;

for_atualizacao:
      atribuicao_for
      {
        $$ = $1;
      }
    | incremento_for
      {
        $$ = $1;
      }
    | /* vazio */
      {
        $$ = NULL;
      }
;

declaracao_for:
      tipo IDENT
      {
        $$ = criar_no(NO_DECLARACAO, $1, NULL, $2);
        free($2);
      }
    | tipo IDENT TK_OP_IGUAL expressao
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2);
        NoAST *atribuicao_inicial = criar_no(NO_ATRIBUICAO, id, $4, "=");
        $$ = criar_no(NO_DECLARACAO, $1, atribuicao_inicial, $2);
        free($2);
      }
;

atribuicao_for:
      IDENT TK_OP_IGUAL expressao
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "=");
        free($1);
      }
    | IDENT TK_OP_MAIS_IGUAL expressao
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "+=");
        free($1);
      }
    | IDENT TK_OP_MENOS_IGUAL expressao
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "-=");
        free($1);
      }
;

incremento_for:
      IDENT TK_OP_INCREMENTO
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pos");
        free($1);
      }
    | IDENT TK_OP_DECREMENTO
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pos");
        free($1);
      }
    | TK_OP_INCREMENTO IDENT
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pre");
        free($2);
      }
    | TK_OP_DECREMENTO IDENT
      {
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pre");
        free($2);
      }
;

expressao_booleana:
      expressao operador_relacional expressao
      {
        /*
         * Expressão relacional.
         * Exemplo: x < 10
         */
        $$ = criar_no(NO_BINARIO, $1, $3, $2);
      }
    | expressao_booleana TK_OP_AND expressao_booleana
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "&&");
      }
    | expressao_booleana TK_OP_OR expressao_booleana
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "||");
      }
    | TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE
      {
        $$ = $2;
      }
;

operador_relacional:
      TK_OP_MENOR
      {
        $$ = "<";
      }
    | TK_OP_MAIOR
      {
        $$ = ">";
      }
    | TK_OP_MENOR_IGUAL
      {
        $$ = "<=";
      }
    | TK_OP_MAIOR_IGUAL
      {
        $$ = ">=";
      }
    | TK_OP_IGUAL_COMPARACAO
      {
        $$ = "==";
      }
    | TK_OP_DIFERENTE
      {
        $$ = "!=";
      }
;

expressao:
      expressao TK_OP_SOMA termo
      {
        /* Expressão binária de soma. Exemplo: a + b */
        $$ = criar_no(NO_BINARIO, $1, $3, "+");
      }
    | expressao TK_OP_SUBTRACAO termo
      {
        /* Expressão binária de subtração. Exemplo: a - b */
        $$ = criar_no(NO_BINARIO, $1, $3, "-");
      }
    | termo
      {
        $$ = $1;
      }
;

termo:
      termo TK_OP_MULTIPLICACAO fator
      {
        /* Expressão binária de multiplicação. Exemplo: a * b */
        $$ = criar_no(NO_BINARIO, $1, $3, "*");
      }
    | termo TK_OP_DIVISAO fator
      {
        /* Expressão binária de divisão. Exemplo: a / b */
        $$ = criar_no(NO_BINARIO, $1, $3, "/");
      }
    | termo TK_OP_MODULO fator
      {
        /* Expressão binária de módulo. Exemplo: a % b */
        $$ = criar_no(NO_BINARIO, $1, $3, "%");
      }
    | fator
      {
        $$ = $1;
      }
;

fator:
      NUMBER
      {
        /* Cria um nó para número. */
        $$ = criar_no(NO_NUMERO, NULL, NULL, $1);
        free($1);
      }
    | IDENT
      {
        /* Cria um nó para identificador. */
        $$ = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1);
        free($1);
      }
    | acesso_vetor
      {
        $$ = $1;
      }
    | TK_ABRE_PARENTESE expressao TK_FECHA_PARENTESE
      {
        $$ = $2;
      }
;

acesso_vetor:
      IDENT TK_ABRE_COLCHETE expressao TK_FECHA_COLCHETE
      {
        /*
         * Acesso a vetor.
         * Exemplo: vetor[i]
         */
        $$ = criar_no(NO_ACESSO_VETOR, $3, NULL, $1);
        free($1);
      }
;

%%

void yyerror(const char *s) {
    printf("Erro sintático: %s\n", s);
}

int main(void) {
    return yyparse();
}
