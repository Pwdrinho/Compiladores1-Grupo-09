#ifndef AST_H
#define AST_H

/*
 * Enum que representa os tipos de nós possíveis na árvore sintática.
 * Cada constante representa uma construção da linguagem:
 * programa, função, declaração, expressão, etc.
 */
typedef enum {
    NO_PROGRAMA,
    NO_LISTA,
    NO_FUNCAO,
    NO_PARAMETRO,
    NO_TIPO,
    NO_BLOCO,

    NO_DECLARACAO,
    NO_ATRIBUICAO,
    NO_RETORNO,

    /*
     * NO_IF usa duas formas por limitação da AST binária:
     * - if sem else: dir aponta direto para o bloco do if
     * - if com else: dir aponta para NO_LISTA(bloco_if, bloco_else)
     */
    NO_IF,
    NO_WHILE,
    NO_FOR,

    NO_BINARIO,
    NO_UNARIO,

    NO_IDENTIFICADOR,
    NO_NUMERO,
    NO_ACESSO_VETOR,

    NO_VAZIO
} TipoNo;

/*
 * Estrutura básica de um nó da AST.
 *
 * tipo  -> indica qual construção esse nó representa.
 * valor -> guarda textos importantes, como nome de variável, número ou operador.
 * esq   -> filho esquerdo.
 * dir   -> filho direito.
 *
 * A árvore foi modelada como binária para simplificar a integração inicial.
 */
typedef struct NoAST {
    TipoNo tipo;
    char *valor;
    struct NoAST *esq;
    struct NoAST *dir;
} NoAST;

/*
 * Cria dinamicamente um novo nó da AST.
 */
NoAST* criar_no(TipoNo tipo, NoAST *esq, NoAST *dir, const char *valor);

/*
 * Imprime a árvore de forma recursiva.
 * Usada principalmente para debug.
 */
void imprimir_ast(NoAST *raiz, int nivel);

/*
 * Libera toda a memória alocada pela AST.
 */
void liberar_ast(NoAST *raiz);

#endif