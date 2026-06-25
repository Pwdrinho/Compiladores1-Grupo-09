## 1. Visão Geral
Na **AST** cada nó na árvore (`NoAST`) encapsula uma unidade sintática (uma operação, uma declaração, um laço de repetição, etc.), mantendo dados para as fases de análise semântica e geração de código.

## 2. Estrutura de Dados (`ast.h`)
O nó é definido por uma estrutura que contém:

* **`TipoNo`**: Um `enum` que categoriza o nó (ex: `NO_IF`, `NO_BINARIO`, `NO_DECLARACAO`).
* **`valor`**: Uma string que guarda literais (números) ou nomes de operadores (usamos a tabela de símbolos apenas para variáveis)
* **`tipo_dado`**: O tipo semântico do nó (ex: `TIPO_DADO_INT`).
* **`simbolo`**: Um ponteiro direto para a **Tabela de Símbolos**, permitindo acesso mais rápido as informações sem precisar de novas buscas, pensamos nisso como uma forma de otimização.
* **Filhos (`esq`, `dir`)**: Ponteiros para os nós descendentes, formando a estrutura de árvore.

## 3. Principais Funcionalidades (`ast.c`)

* **`criar_no`**: Construtor que aloca o nó e inicializa seus campos.
* **`imprimir_ast`**: Imprimi a árvore, sua função é para visualização e debugs.
* **`liberar_ast`**: Implementação de um percurso pós-ordem para desalocação de memória, chamada apenas no final, pensada também como uma maneira de otimização.

## 4. Pipeline de Execução
A AST atua como o meio de troca principal entre as etapas do compilador:

1. **Parser (`parser.y`)**: Constrói os nós à medida que reconhece a gramática.
2. **Analisador Semântico**: Preenche o campo `tipo_dado` e verifica erros semânticos.