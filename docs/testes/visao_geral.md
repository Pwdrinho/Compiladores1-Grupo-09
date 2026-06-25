# Testes — Visão Geral

A suíte de testes do compilador é baseada em comparação de saídas: para cada caso existe um arquivo de entrada (`.c`) e um gabarito (`.out`). O Makefile compila o módulo correspondente, executa cada entrada e compara o resultado com o gabarito via `diff`, imprimindo `PASS`/`FAIL` por caso.

## Estrutura de diretórios

```
tests/
├── scanner/
│   ├── inputs/      # entradas do léxico (.c)
│   └── expected/    # gabaritos de tokens (.out)
└── parser/
    ├── inputs/      # entradas do sintático (.c)
    └── expected/    # gabaritos de AST (.out)
```

## Comandos do Makefile

Todos os comandos devem ser executados a partir da raiz do projeto.

| Comando | O que faz |
|---------|-----------|
| `make test` | Executa scanner-test + parser-test |
| `make scanner-test` | Compila o lexer e roda todos os testes do scanner |
| `make parser-test` | Compila o compilador e roda todos os testes do parser |
| `make scanner-unit-test TEST=n` | Roda um teste do scanner pelo número |
| `make scanner-unit-test TEST=nome` | Roda um teste do scanner pelo nome base do arquivo |
| `make parser-unit-test TEST=n` | Roda um teste do parser pelo número |
| `make parser-unit-test TEST=nome` | Roda um teste do parser pelo nome base do arquivo |
| `make scanner-test DEBUG=1` | Imprime expected/actual mesmo em testes que passam |
| `make parser-test DEBUG=1` | Imprime expected/actual mesmo em testes que passam |
| `make coverage` | Gera relatório HTML de cobertura unificado |
| `make clean` | Remove artefatos de build |

### Exemplos

```bash
# rodar tudo
make test

# teste individual do scanner por número
make scanner-unit-test TEST=3

# teste individual do scanner por nome
make scanner-unit-test TEST=03_double_operators

# teste individual do parser por número
make parser-unit-test TEST=2

# teste individual do parser por nome
make parser-unit-test TEST=02_function_with_params_and_if
```

## Cobertura de Código

### Ferramentas

A cobertura é medida com **Gcov** e visualizada com **LCOV**.

- **Gcov**: instrumentação nativa do GCC, ativada pelas flags `-fprofile-arcs -ftest-coverage` (configuradas no `Makefile` via `COV_FLAGS`). Gera arquivos `.gcda` e `.gcno` durante a execução dos testes.
- **LCOV**: agrega os dados do Gcov e produz relatórios HTML navegáveis com destaque de linhas cobertas (verde), parcialmente cobertas (amarelo) e não cobertas (vermelho).

O relatório é gerado de forma **unificada**: os dados do scanner e do parser são mesclados com `lcov --add-tracefile` antes de gerar o HTML, então a cobertura de ambos os módulos aparece no mesmo relatório.

Arquivos gerados automaticamente (`lex.yy.c`, `parser.tab.c`) e cabeçalhos do sistema (`/usr/*`) são excluídos automaticamente pelo `Makefile`.

### Gerar o relatório

```bash
make coverage
```

Ao final, o caminho do arquivo principal é impresso no terminal:

```
Relatório GLOBAL de cobertura gerado com sucesso em: build/coverage-html/index.html
```

### Abrir no navegador

```bash
# Linux / WSL
xdg-open build/coverage-html/index.html

# macOS
open build/coverage-html/index.html
```

> `xdg-open` faz parte do pacote `xdg-utils`, que já vem instalado por padrão no Ubuntu e Debian — inclusive no WSL. Não é necessário instalar nada além do ambiente base do projeto.