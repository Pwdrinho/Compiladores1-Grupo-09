# Compiladores1-Grupo-09

Projeto do grupo 09 da disciplina de Compiladores 1. O objetivo é traduzir um
subconjunto da linguagem C para Go usando as etapas clássicas de um compilador:
análise léxica, análise sintática, AST, validações semânticas básicas, código
intermediário para depuração e geração de código final.

## Subconjunto suportado

O compilador não tenta implementar C completo. O foco atual é uma entrega
acadêmica demonstrável com:

- funções simples;
- parâmetros `int`, `float` e `void`;
- declaração de variáveis e arrays simples;
- atribuições;
- expressões aritméticas e relacionais;
- `if`/`else`;
- `while`;
- `for`;
- `return`;
- incremento/decremento como comando;
- chamadas simples de função.

As validações semânticas atuais cobrem assinaturas de funções, chamadas para
função inexistente, quantidade de argumentos, retornos incompatíveis com o tipo
da função e divisão literal por zero.

## Como compilar

```bash
make all
```

O executável é gerado em:

```bash
build/compilador
```

## Como executar

Usando o script:

```bash
chmod +x compilador_grupo09.sh
./compilador_grupo09.sh arquivo.c
```

Ou diretamente pelo executável:

```bash
build/compilador < arquivo.c
```

A saída Go final é gerada em:

```bash
saida.go
```

## Testes

```bash
make test
```

Também é possível rodar por etapa:

```bash
make scanner-test
make parser-test
make codegen-test
```

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

Saída Go gerada:

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
