# Testes do Léxico

Testes do analisador léxico (`src/lexer/scanner.l`). Cada caso valida o reconhecimento de uma classe de tokens, comparando a saída do scanner com um gabarito.

Para entender a metodologia geral, os comandos do Makefile e como gerar o relatório de cobertura, consulte [testes.md](../testes.md).

## Casos de Teste

| # | Arquivo | O que cobre |
|---|---------|-------------|
| 01 | `01_keywords.c` | Todas as 32 palavras reservadas do padrão ANSI C (`int`, `return`, `if`, `while`, …) |
| 02 | `02_identifiers_numbers.c` | Identificadores válidos (underscore, maiúsculas/minúsculas) e literais numéricos inteiros e de ponto flutuante |
| 03 | `03_double_operators.c` | Operadores compostos (`==`, `!=`, `<=`, `>=`, `&&`, `||`, …) |
| 04 | `04_single_operators_delimiters.c` | Operadores simples e delimitadores (`+`, `-`, `*`, `;`, `{`, `}`, …) |
| 05 | `05_comments_whitespace.c` | Comentários de linha (`//`) e de bloco (`/* … */`) — verificação de que não geram tokens espúrios |
| 06 | `06_unknown_chars.c` | Caracteres inválidos (`@`, `$`) — testa a regra de fallback do scanner |
| 07 | `07_mixed_snippet.c` | Mistura de tokens representativos de código real |
| 08 | `08_simple_program.c` | Programa simples completo |
| 09 | `09_function_and_condition.c` | Função com condicional |
| 10 | `10_pointers_arrays.c` | Ponteiros e arrays |
| 11 | `11_trailing_dot_literal.c` | Caso especial: `10.` é tokenizado como `NUMBER(10)` seguido de `TK_OP_PONTO` |
| 12 | `12_unclosed_block_comment.c` | Comentário de bloco não fechado — testa resiliência do lexer quando o arquivo termina sem `*/` |

### Caráter dos testes

Os testes 01–10 são **atômicos e essenciais**: cada um isola uma classe de tokens e cobre quase todas as linhas relevantes do scanner individualmente.

Os testes 11 e 12 são de **contexto e erro**: validam comportamentos de borda críticos para a robustez do compilador.

> Testes de código estruturado (funções, loops) têm menor impacto na cobertura do léxico porque o lexer processa caracteres individualmente, sem enxergar estrutura sintática.