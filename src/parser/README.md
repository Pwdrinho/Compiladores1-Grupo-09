# Parser — Analisador Sintático

_Analisador sintático em Bison integrado ao scanner (Flex) e à AST do projeto._

## Visão geral

Este diretório contém o analisador sintático escrito em Bison (`src/parser/parser.y`). O parser recebe tokens do scanner, constrói a Árvore Sintática Abstrata (AST) e imprime a árvore ao final da análise.

A tabela de símbolos (`src/symbols/symtab.*`) é compilada junto ao projeto, mas sua integração com as regras gramaticais ainda não foi implementada — nenhum símbolo é inserido ou consultado durante o parsing.

## Estrutura dos arquivos

```
src/
├── parser/
│   └── parser.y        # Gramática e ações semânticas (Bison)
├── ast/
│   ├── ast.h           # Definição dos tipos de nó e API da AST
│   └── ast.c           # Implementação: criar_no, imprimir_ast, liberar_ast
├── symbols/
│   ├── symtab.h        # Tabela de símbolos (hash com encadeamento)
│   └── symtab.c        # Implementação: inserir, buscar, remover por escopo
└── lexer/
    └── scanner.l       # Scanner Flex (fonte dos tokens)
```

## O que a gramática suporta hoje

### Declarações
```c
int x;
int x = 10 + 2;
int v[10];
```

### Atribuição simples
```c
x = x - 1;
```

### Incremento e decremento (como comando isolado)
```c
i++;
i--;
++i;
--i;
```

### Estruturas de controle
```c
if (a < b) { ... }
if (a < b) { ... } else { ... }
while (a != 0) { ... }
for (int i = 0; i < 10; i++) { ... }
```

### Expressões aritméticas
```c
a + b * c - d / e % f
```

### Expressões relacionais e lógicas (em condições)
```c
a < b
a >= b
a == b
a != b
expr && expr
expr || expr
```

### Funções
```c
int soma(int a, int b) { ... }
void main() { ... }
```

### Tipos suportados
`int`, `float`, `void`

## Limitações conhecidas

- **Chamadas de função não são expressões.** `return soma(a, b);` ou `x = foo();` causam erro sintático. A gramática reconhece apenas definições de função, não invocações.
- **Operador `!` não está na gramática.** O scanner tokeniza `!` como `TK_OP_NAO`, mas nenhuma regra o consome. `if (!flag)` causa erro sintático.
- **`+=`, `-=`, `*=` só funcionam dentro do `for`.** Como comando geral (`a += 2;` fora de um `for`) causam erro sintático.
- **Condição booleana simples não é aceita.** `while (flag)` ou `if (x)` causam erro — a gramática exige uma expressão relacional completa (`x != 0`, por exemplo).
- **Apenas três tipos primitivos.** `char`, `double`, `long` e demais tipos do C são tokenizados como palavras reservadas mas não têm regra no parser.
- **Sem suporte a strings ou literais de caractere.** `"texto"` e `'a'` não são reconhecidos pelo scanner.
- **Tabela de símbolos não integrada.** `symtab.h` é incluído, mas `inserir_simbolo`, `buscar_simbolo` e `remover_escopo` não são chamados em nenhuma regra.
- **Sem rastreamento de linha/coluna nos erros.** `yyerror()` imprime apenas a mensagem genérica do Bison, sem indicar onde no arquivo ocorreu o erro.

## Requisitos

- Bison ≥ 3.x
- Flex
- GCC e Make

## Compilar

A partir da raiz do projeto:

```bash
make
```

O Makefile gera `build/parser.tab.c`, `build/parser.tab.h`, `build/lex.yy.c` e linka tudo em `build/compilador`.

Para limpar os artefatos:

```bash
make clean
```

## Uso

O binário lê da entrada padrão:

```bash
./build/compilador < teste.c
```

Ao terminar sem erros, imprime:

```
Análise sintática concluída
```

seguido da AST com indentação. Em caso de erro sintático, imprime:

```
Erro sintático: syntax error
```

## Testes

### Scanner

Os testes do scanner estão implementados e funcionando:

```bash
make scanner-test
```

Compara a saída do scanner para cada arquivo em `tests/scanner/inputs/*.c` contra o gabarito em `tests/scanner/expected/*.out`.

Para um teste individual:

```bash
make scanner-unit-test TEST=7
make scanner-unit-test TEST=07_mixed_snippet
```

### Parser

Os testes do parser agora seguem o mesmo padrão de entrada/saída do scanner:

```bash
make parser-test
```

ou:

```bash
make test
```

Eles comparam `tests/parser/inputs/*.c` com os gabaritos em `tests/parser/expected/*.out`, usando como saída principal a AST impressa pelo compilador. A tabela de símbolos continua sendo compilada junto ao projeto, mas ainda não é o foco principal da suíte.

## Depuração

Para habilitar a impressão de tokens durante a análise, compile com `DEBUG_LEXER=1`:

```bash
make clean && make CFLAGS="-Wall -Wextra -g -DDEBUG_LEXER=1"
```

Para ativar o trace interno do Bison, adicione `%debug` ao topo de `parser.y` e chame `yydebug = 1;` no `main`.

## Contribuição

Siga os padrões descritos em:

- `docs/manuais/padrao_commit.md` — formato de commits
- `docs/manuais/padrao_branch.md` — nomenclatura de branches

Antes de abrir um PR, rode `make` e `make scanner-test` sem erros.