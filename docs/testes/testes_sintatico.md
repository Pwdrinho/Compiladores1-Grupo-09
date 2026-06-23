# Testes do Sintático

Testes do analisador sintático (`src/parser/parser.y`). Os casos verificam se o parser reconhece programas válidos e rejeita programas inválidos, comparando a saída completa do compilador, **AST com tabela de símbolos, código intermediário e mensagem do gerador**, com saídas de referência em `tests/parser/expected/`.

Para entender a metodologia geral, os comandos do Makefile e como gerar o relatório de cobertura, consulte [visão geral](./visao_geral.md).

## Casos de Teste

### Sintaxe válida (caminho feliz)

| # | Arquivo | O que cobre |
|---|---------|-------------|
| 01 | `01_simple_function.c` | Função simples sem parâmetros |
| 02 | `02_function_with_params_and_if.c` | Função com parâmetros e condicional `if` |
| 03 | `03_local_decl_increment_return.c` | Declaração local, incremento e `return` com valor |
| 04 | `04_vector_access.c` | Acesso a vetor por índice |
| 05 | `05_for_loop.c` | Estrutura de repetição `for` |
| 06 | `06_if_else.c` | Condicional `if/else` |
| 07 | `07_multiple_functions.c` | Múltiplas funções no mesmo arquivo |
| 08 | `08_while_prefix_return_void.c` | `while`, operadores prefixados (`++`/`--`) e `return` sem valor |
| 10 | `10_binary_mul_div_mod.c` | Operadores aritméticos `*`, `/` e `%` |
| 11 | `11_boolean_and_or_ne.c` | Operadores lógicos `&&`, `\|\|` e desigualdade `!=` |
| 12 | `12_for_compound_assign.c` | Uso de atribuição composta em laços `for` |
| 13 | `13_for_empty_parts.c` | Estrutura `for` com partes opcionais vazias |
| 14 | `14_decrement_post.c` | Operador pós-decremento (`x--`) |
| 15 | `15_nested_block.c` | Blocos aninhados |
| 16 | `16_decl_init_expr.c` | Declaração com inicialização por expressão |
| 17 | `17_nested_if.c` | Estruturas `if` aninhadas |
| 19 | `19_for_assign_init.c` | Inicialização por atribuição em `for` |
| 20 | `20_for_all_empty.c` | `for (;;)` com todas as partes vazias |
| 24 | `24_for_prefix_update.c` | Atualização com operador prefixado em `for` |
| 27 | `27_float_bool_parens_eq.c` | Tipos `float`, expressões parentizadas e igualdade |

### Sintaxe inválida (tratamento de erros)

| # | Arquivo | O que documenta |
|---|---------|-----------------|
| 09 | `09_function_call_not_supported.c` | Chamada de função como statement — não suportada pela gramática |
| 21 | `21_unclosed_brace.c` | Bloco não encerrado (`}` ausente) |
| 23 | `23_missing_semicolon.c` | Ausência de ponto e vírgula |

## O que a suíte cobre

- Declarações locais com e sem inicialização, incluindo vetores
- Funções com e sem parâmetros, tipos `int`, `float` e `void`
- Tabela de símbolos: inserção, consulta e marcação `[Ativo]` por escopo
- Estruturas condicionais (`if` e `if/else`, incluindo aninhamento)
- Estruturas de repetição (`while` e `for` em todas as variações de init/update)
- Blocos aninhados
- Operadores aritméticos (`+`, `-`, `*`, `/`, `%`), relacionais (`<`, `>`, `<=`, `>=`, `==`, `!=`) e lógicos (`&&`, `||`)
- Operadores unários prefixados (`++pre`, `--pre`) e pós-fixados (`++pos`, `--pos`)
- Geração de código intermediário e saída Go
- Erros sintáticos comuns