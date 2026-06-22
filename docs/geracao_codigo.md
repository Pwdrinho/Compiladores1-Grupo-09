# Geração de Código C para Go

Esta etapa percorre a AST e gera um arquivo Go equivalente para o subconjunto de C
suportado pelo projeto. O arquivo de saída padrão é:

```text
saida.go
```

## Fluxo

1. O Flex transforma o código C em tokens.
2. O Bison valida a gramática e constrói a AST.
3. A tabela de símbolos registra variáveis e escopos.
4. A análise semântica preenche tipos básicos e detecta alguns erros.
5. O gerador percorre a AST e escreve o código Go final.
6. O código intermediário continua sendo impresso para depuração.

## Construções traduzidas

| C | Go |
|---|----|
| `int x = 1;` | `var x int = 1` |
| `x = x + 1;` | `x = (x + 1)` |
| `while (x < 3) { ... }` | `for (x < 3) { ... }` |
| `if (...) { ... } else { ... }` | `if ... { ... } else { ... }` |
| `return expr;` em função comum | `return expr` |
| `return expr;` em `main` | `fmt.Println(expr); return` |
| `soma(2, 3)` | `soma(2, 3)` |

Chamadas para funções definidas depois do ponto de uso também são aceitas, porque
a análise semântica coleta as assinaturas antes de validar as chamadas.

## Exemplo

Entrada C:

```c
int soma(int a, int b) {
    return a + b;
}

int main() {
    int r = soma(2, 3);
    return r;
}
```

Saída Go:

```go
package main

import "fmt"

func soma(a int, b int) int {
    return (a + b)
}

func main() {
    var r int = soma(2, 3)
    fmt.Println(r)
    return
}
```

## Testes

Os testes de geração ficam em:

```text
tests/codegen/inputs/
tests/codegen/expected/
```

Para executar:

```bash
make codegen-test
```

O teste compila cada entrada C, captura o `saida.go` gerado e compara com o Go
esperado.

## Limitações assumidas

O projeto não implementa C completo. Ponteiros, `struct`, `union`, `typedef`,
`include`, alocação dinâmica e biblioteca padrão de C ficam fora do escopo atual.
O objetivo é manter um subconjunto pequeno, correto e demonstrável.
