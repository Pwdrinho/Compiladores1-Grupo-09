# Testes do Analisador Sintático

Os testes sintáticos validam se o parser aceita programas do subconjunto suportado
e constrói a AST esperada. Eles também exercitam a integração com tabela de
símbolos, análise semântica básica, código intermediário e geração final em Go.

## Como executar

```bash
make parser-test
```

Para rodar todos os testes do projeto:

```bash
make test
```

## Estrutura

```text
tests/parser/inputs/
tests/parser/expected/
```

- `inputs/*.c`: programas C usados como entrada.
- `expected/*.out`: saída esperada do compilador, incluindo AST e código intermediário.

## Casos cobertos

- função simples com `return`;
- parâmetros de função;
- declaração local;
- atribuição;
- incremento e decremento;
- acesso simples a vetor;
- `for`;
- `if` e `else`;
- múltiplas funções;
- `while`;
- chamada simples de função.

## Observação

Os testes do parser não validam a saída Go final. Essa responsabilidade fica com
os testes de geração de código:

```bash
make codegen-test
```
