%code requires {
    #include "ast.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "symtab.h"
#include "semantico.h"
#include "intermediario.h"
#include "gerador.h"

int yylex(void);

void yyerror(const char *s);

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

%type <no> programa
%type <no> lista_elementos elemento 
%type <no> funcao
%type <no> parametros lista_parametros parametro
%type <no> tipo bloco lista_comandos comando
%type <no> declaracao atribuicao incremento retorno
%type <no> comando_if comando_while comando_for
%type <no> for_init for_condicao for_atualizacao
%type <no> declaracao_for atribuicao_for incremento_for
%type <no> expressao_booleana expressao termo fator acesso_vetor
%type <str> operador_relacional

%%

// lista elementos ao ivés de funções para permitir variáveis globais
programa:
      lista_elementos
      {

        raiz_ast = criar_no(NO_PROGRAMA, $1, NULL, NULL, NULL);
        $$ = raiz_ast;

        printf("\n");
        printf("------------\n");
        printf("\n");

        // analise sintatica
        analisar_semantica(raiz_ast);

        printf("Análise sintática e semântica concluídas com sucesso.\n");

        printf("\n");
        printf("------------\n");
        printf("\n");
        printf("AST \n");
        printf("\n");

        imprimir_ast(raiz_ast, 0);


        // Geração do Código Intermediário
        Intermediario *codigo_intermediario = gerar_codigo_intermediario(raiz_ast);

        // Geração do Código Final
        gerar_codigo_go(codigo_intermediario, "saida.go");

        imprimir_codigo_intermediario(codigo_intermediario);

        liberar_ast(raiz_ast);
        printf("Liberamos a memoria da arvore sintatica \n");

      }
;

lista_elementos:
      lista_elementos elemento
      {
        $$ = criar_no(NO_LISTA, $1, $2, NULL, NULL);
      }
    | elemento
      {
        $$ = $1;
      }
;

elemento:
      funcao
      { $$ = $1; }
    | declaracao
      { $$ = $1; }
;

funcao:
      tipo IDENT TK_ABRE_PARENTESE 
      { entrar_escopo(); } /* Protege os parâmetros */
      parametros TK_FECHA_PARENTESE bloco
      {
        NoAST *cabecalho = criar_no(NO_LISTA, $1, $5, NULL, NULL);
        $$ = criar_no(NO_FUNCAO, cabecalho, $7, $2, NULL);
        free($2);
        
        sair_escopo(); /* Limpa as variáveis ao fim da função */
      }
;

parametros:
      lista_parametros { $$ = $1; }
    | /* vazio */ { $$ = NULL; }
;

lista_parametros:
      lista_parametros TK_OP_VIRGULA parametro
      {
        $$ = criar_no(NO_LISTA, $1, $3, NULL, NULL);
      }
    | parametro
      {
        $$ = $1;
      }
;

parametro:
      tipo IDENT
      {
        // Insere o parâmetro na tabela de símbolos para o escopo da função
        if (buscar_simbolo_escopo($2, escopo_atual) != NULL) {
            printf("Erro Semântico: Parâmetro '%s' duplicado.\n", $2);
            exit(1);
        }
        inserir_simbolo($2, $1->tipo_dado, escopo_atual);
        Simbolo *simb = buscar_simbolo($2);
        
        $$ = criar_no(NO_PARAMETRO, $1, NULL, $2, simb);
        free($2);
      }
;

// insere o tipo de dado
tipo:
      KW_INT
      {
        $$ = criar_no(NO_TIPO, NULL, NULL, "int", NULL);
        $$->tipo_dado = TIPO_DADO_INT;
      }
    | KW_FLOAT
      {
        $$ = criar_no(NO_TIPO, NULL, NULL, "float", NULL);
        $$->tipo_dado = TIPO_DADO_FLOAT;
      }
    | KW_VOID
      {
        $$ = criar_no(NO_TIPO, NULL, NULL, "void", NULL);
        $$->tipo_dado = TIPO_DADO_VOID;
      }
;

bloco:
      TK_ABRE_CHAVE 
      { entrar_escopo(); } /* Novo escopo local para o bloco { } */
      lista_comandos 
      TK_FECHA_CHAVE
      {
        $$ = criar_no(NO_BLOCO, $3, NULL, NULL, NULL);
        sair_escopo(); /* Destroi variáveis locais */
      }
;

lista_comandos:
      lista_comandos comando
      {
        $$ = criar_no(NO_LISTA, $1, $2, NULL, NULL);
      }
    | /* vazio */
      {
        $$ = NULL;
      }
;

comando:
      declaracao { $$ = $1; }
    | atribuicao { $$ = $1; }
    | retorno { $$ = $1; }
    | comando_if { $$ = $1; }
    | comando_while { $$ = $1; }
    | comando_for { $$ = $1; }
    | incremento { $$ = $1; }
    | bloco { $$ = $1; }
;

declaracao:
      tipo IDENT TK_OP_PONTO_VIRGULA
      {
        // verifica duplicidade estrita
        if (buscar_simbolo_escopo($2, escopo_atual) != NULL) {
            printf("Erro Semântico: Variável '%s' já declarada neste escopo.\n", $2);
            exit(1);
        }
        
        // insere na tabela extraindo o tipo_dado que veio da regra 'tipo'
        inserir_simbolo($2, $1->tipo_dado, escopo_atual);
        
        // pega o ponteiro da variavel
        Simbolo *simb = buscar_simbolo($2);
        
        // cria a AST com o endereço da variavel na tabela de simbolos
        $$ = criar_no(NO_DECLARACAO, $1, NULL, $2, simb);
        free($2);
      }
    | tipo IDENT TK_OP_IGUAL expressao TK_OP_PONTO_VIRGULA
      {
        if (buscar_simbolo_escopo($2, escopo_atual) != NULL) {
            printf("Erro Semântico: Variável '%s' já declarada.\n", $2);
            exit(1);
        }
        inserir_simbolo($2, $1->tipo_dado, escopo_atual);
        Simbolo *simb = buscar_simbolo($2);

        // o filho identificador com o ponteiro
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2, simb);
        
        // atribuição
        NoAST *atribuicao_inicial = criar_no(NO_ATRIBUICAO, id, $4, "=", NULL);
        
        $$ = criar_no(NO_DECLARACAO, $1, atribuicao_inicial, $2, simb);
        free($2);
      }
    | tipo IDENT TK_ABRE_COLCHETE NUMBER TK_FECHA_COLCHETE TK_OP_PONTO_VIRGULA
      {
        if (buscar_simbolo_escopo($2, escopo_atual) != NULL) {
            printf("Erro Semântico: Vetor '%s' já declarado.\n", $2);
            exit(1);
        }
        inserir_simbolo($2, $1->tipo_dado, escopo_atual);
        Simbolo *simb = buscar_simbolo($2);

        NoAST *tamanho = criar_no(NO_NUMERO, NULL, NULL, $4, NULL);
        $$ = criar_no(NO_DECLARACAO, $1, tamanho, $2, simb);
        free($2);
        free($4);
      }
;

atribuicao:
      IDENT TK_OP_IGUAL expressao TK_OP_PONTO_VIRGULA
      {
        // busca tudo ativo
        Simbolo *simb = buscar_simbolo($1);
        if (simb == NULL) {
            printf("Erro Semântico: Atribuição a variável não declarada '%s'.\n", $1);
            exit(1);
        }
        
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, simb);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "=", NULL);
        free($1);
      }
;

incremento:
      IDENT TK_OP_INCREMENTO TK_OP_PONTO_VIRGULA
      {
        Simbolo *simb = buscar_simbolo($1);
        if (simb == NULL) { printf("Erro: Variável não declarada '%s'.\n", $1); exit(1); }
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, simb);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pos", NULL);
        free($1);
      }
    | IDENT TK_OP_DECREMENTO TK_OP_PONTO_VIRGULA
      {
        Simbolo *simb = buscar_simbolo($1);
        if (simb == NULL) { printf("Erro: Variável não declarada '%s'.\n", $1); exit(1); }
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, simb);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pos", NULL);
        free($1);
      }
    | TK_OP_INCREMENTO IDENT TK_OP_PONTO_VIRGULA
      {
        Simbolo *simb = buscar_simbolo($2);
        if (simb == NULL) { printf("Erro: Variável não declarada '%s'.\n", $2); exit(1); }
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2, simb);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pre", NULL);
        free($2);
      }
    | TK_OP_DECREMENTO IDENT TK_OP_PONTO_VIRGULA
      {
        Simbolo *simb = buscar_simbolo($2);
        if (simb == NULL) { printf("Erro: Variável não declarada '%s'.\n", $2); exit(1); }
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2, simb);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pre", NULL);
        free($2);
      }
;

retorno:
      KW_RETURN expressao TK_OP_PONTO_VIRGULA
      {
        $$ = criar_no(NO_RETORNO, $2, NULL, NULL, NULL);
      }
    | KW_RETURN TK_OP_PONTO_VIRGULA
      {
        $$ = criar_no(NO_RETORNO, NULL, NULL, NULL, NULL);
      }
;

comando_if:
      KW_IF TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco %prec LOWER_THAN_ELSE
      {
        $$ = criar_no(NO_IF, $3, $5, "if", NULL);
      }
    | KW_IF TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco KW_ELSE bloco
      {
        NoAST *blocos = criar_no(NO_LISTA, $5, $7, NULL, NULL);
        $$ = criar_no(NO_IF, $3, blocos, "if_else", NULL);
      }
;

comando_while:
      KW_WHILE TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE bloco
      {
        $$ = criar_no(NO_WHILE, $3, $5, NULL, NULL);
      }
;

comando_for:
      KW_FOR TK_ABRE_PARENTESE for_init TK_OP_PONTO_VIRGULA for_condicao TK_OP_PONTO_VIRGULA for_atualizacao TK_FECHA_PARENTESE bloco
      {
        NoAST *cabecalho_parcial = criar_no(NO_LISTA, $3, $5, NULL, NULL);
        NoAST *cabecalho = criar_no(NO_LISTA, cabecalho_parcial, $7, NULL, NULL);
        $$ = criar_no(NO_FOR, cabecalho, $9, NULL, NULL);
      }
;

for_init:
      declaracao_for { $$ = $1; }
    | atribuicao_for { $$ = $1; }
    | /* vazio */ { $$ = NULL; }
;

for_condicao:
      expressao_booleana { $$ = $1; }
    | /* vazio */ { $$ = NULL; }
;

for_atualizacao:
      atribuicao_for { $$ = $1; }
    | incremento_for { $$ = $1; }
    | /* vazio */ { $$ = NULL; }
;

declaracao_for:
      tipo IDENT
      {
        if (buscar_simbolo_escopo($2, escopo_atual) != NULL) { exit(1); }
        inserir_simbolo($2, $1->tipo_dado, escopo_atual);
        Simbolo *simb = buscar_simbolo($2);
        $$ = criar_no(NO_DECLARACAO, $1, NULL, $2, simb);
        free($2);
      }
    | tipo IDENT TK_OP_IGUAL expressao
      {
        if (buscar_simbolo_escopo($2, escopo_atual) != NULL) { exit(1); }
        inserir_simbolo($2, $1->tipo_dado, escopo_atual);
        Simbolo *simb = buscar_simbolo($2);

        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2, simb);
        NoAST *atribuicao_inicial = criar_no(NO_ATRIBUICAO, id, $4, "=", NULL);
        $$ = criar_no(NO_DECLARACAO, $1, atribuicao_inicial, $2, simb);
        free($2);
      }
;

atribuicao_for:
      IDENT TK_OP_IGUAL expressao
      {
        Simbolo *s = buscar_simbolo($1); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, s);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "=", NULL);
        free($1);
      }
    | IDENT TK_OP_MAIS_IGUAL expressao
      {
        Simbolo *s = buscar_simbolo($1); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, s);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "+=", NULL);
        free($1);
      }
    | IDENT TK_OP_MENOS_IGUAL expressao
      {
        Simbolo *s = buscar_simbolo($1); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, s);
        $$ = criar_no(NO_ATRIBUICAO, id, $3, "-=", NULL);
        free($1);
      }
;

incremento_for:
      IDENT TK_OP_INCREMENTO
      {
        Simbolo *s = buscar_simbolo($1); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, s);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pos", NULL);
        free($1);
      }
    | IDENT TK_OP_DECREMENTO
      {
        Simbolo *s = buscar_simbolo($1); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, s);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pos", NULL);
        free($1);
      }
    | TK_OP_INCREMENTO IDENT
      {
        Simbolo *s = buscar_simbolo($2); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2, s);
        $$ = criar_no(NO_UNARIO, id, NULL, "++pre", NULL);
        free($2);
      }
    | TK_OP_DECREMENTO IDENT
      {
        Simbolo *s = buscar_simbolo($2); if(!s) exit(1);
        NoAST *id = criar_no(NO_IDENTIFICADOR, NULL, NULL, $2, s);
        $$ = criar_no(NO_UNARIO, id, NULL, "--pre", NULL);
        free($2);
      }
;

expressao_booleana:
      expressao operador_relacional expressao
      {
        $$ = criar_no(NO_BINARIO, $1, $3, $2, NULL);
      }
    | expressao_booleana TK_OP_AND expressao_booleana
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "&&", NULL);
      }
    | expressao_booleana TK_OP_OR expressao_booleana
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "||", NULL);
      }
    | TK_ABRE_PARENTESE expressao_booleana TK_FECHA_PARENTESE
      {
        $$ = $2;
      }
;

operador_relacional:
      TK_OP_MENOR { $$ = "<"; }
    | TK_OP_MAIOR { $$ = ">"; }
    | TK_OP_MENOR_IGUAL { $$ = "<="; }
    | TK_OP_MAIOR_IGUAL { $$ = ">="; }
    | TK_OP_IGUAL_COMPARACAO { $$ = "=="; }
    | TK_OP_DIFERENTE { $$ = "!="; }
;

expressao:
      expressao TK_OP_SOMA termo
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "+", NULL);
      }
    | expressao TK_OP_SUBTRACAO termo
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "-", NULL);
      }
    | termo
      {
        $$ = $1;
      }
;

termo:
      termo TK_OP_MULTIPLICACAO fator
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "*", NULL);
      }
    | termo TK_OP_DIVISAO fator
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "/", NULL);
      }
    | termo TK_OP_MODULO fator
      {
        $$ = criar_no(NO_BINARIO, $1, $3, "%", NULL);
      }
    | fator
      {
        $$ = $1;
      }
;

fator:
      NUMBER
      {
        $$ = criar_no(NO_NUMERO, NULL, NULL, $1, NULL);
        free($1);
      }
    | IDENT
      {
        // bloqueia se a variável não existir
        Simbolo *simb = buscar_simbolo($1);
        if (simb == NULL) {
            printf("Erro Semântico: Variável '%s' não declarada.\n", $1);
            exit(1);
        }
        $$ = criar_no(NO_IDENTIFICADOR, NULL, NULL, $1, simb);
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
        Simbolo *simb_v = buscar_simbolo($1);
        $$ = criar_no(NO_ACESSO_VETOR, $3, NULL, $1, simb_v);
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