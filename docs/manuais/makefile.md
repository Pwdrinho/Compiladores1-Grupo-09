# Manual Básico de Makefile (para projetos com Flex e Bison)

## 1. Introdução

O **Makefile** é um arquivo utilizado para **automatizar o processo de compilação** de programas.
Em vez de executar manualmente vários comandos no terminal (como `flex`, `bison` e `gcc`), o Makefile permite executar tudo com apenas um comando:

```
make
```

O programa responsável por interpretar esse arquivo é o **GNU Make**.

Em ambientes de desenvolvimento para compiladores (como aqueles que utilizam **Flex** e **Bison**), o `make` normalmente **já vem instalado** ou é instalado junto com pacotes de desenvolvimento como:

* `flex`
* `bison`
* `build-essential` (Linux/WSL)

Por isso, na maioria dos casos **não é necessário instalar nada adicional**.

Para verificar se o `make` está disponível:

```
make --version
```

## 1.1 Vantagens

O uso do Makefile traz várias vantagens:

- Automatiza a compilação;
- Evita digitar comandos repetitivos;
- Recompila apenas arquivos modificados;
- Organiza projetos maiores;
- Limpa arquivos intermediários gerados pelo flex e bison.

# 2. O que é um Makefile

O **Makefile** é simplesmente um arquivo de texto chamado:

```
Makefile
```

Ele contém **regras** que dizem ao `make`:

* o que deve ser construído
* quais arquivos são dependências
* quais comandos devem ser executados

# 3. Estrutura de uma Regra

A estrutura básica de uma regra no Makefile é:

```
alvo: dependencias
[TAB] comando
```

Onde:

* **alvo (target)** → arquivo que será gerado
* **dependências** → arquivos necessários para gerar o alvo
* **comando** → instrução executada no terminal

***Importante***:
O comando deve começar com **TAB**, não espaços.

# 4. Exemplo Simples

Exemplo de um Makefile para compilar um programa em C:

```
programa: main.c
	gcc main.c -o programa
```

Execução:

```
make
```

Resultado:

```
gcc main.c -o programa
```

# 5. Makefile para Flex e Bison

Em projetos que utilizam **Flex e Bison**, normalmente temos arquivos como:

```
lexer.l
parser.y
teste.c
```

Durante a compilação são gerados:

```
lex.yy.c
parser.tab.c
parser.tab.h
```

Um exemplo de Makefile para esse caso é:

```
all: analisador

analisador: lex.yy.c parser.tab.c
	gcc lex.yy.c parser.tab.c -o analisador -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l
```

Esse Makefile realiza:

1. Geração do parser com **Bison**
2. Geração do analisador léxico com **Flex**
3. Compilação com **gcc**

# 6. Regra de Limpeza

É comum adicionar uma regra chamada **clean**, usada para remover arquivos gerados automaticamente.

Exemplo:

```
clean:
	rm -f lex.yy.c parser.tab.c parser.tab.h analisador
```

Execução:

```
make clean
```

Isso remove todos os arquivos gerados durante a compilação.

# 7. Executando o Programa

Após compilar com:

```
make
```

o executável pode ser utilizado normalmente.

Exemplo com um arquivo de teste:

```
./analisador < teste.c
```

# 8. Fluxo de Uso

Fluxo típico de uso em um projeto com Flex/Bison:

## 8.1 Compilar o projeto

```
make
```

## 8.2 Executar o analisador

```
./analisador < teste.c
```

## 8.3 Limpar arquivos gerados

```
make clean
```

# 9. Conclusão

O **Makefile** é uma ferramenta essencial para automatizar o processo de compilação.
Em projetos que utilizam **Flex e Bison**, ele facilita a geração dos arquivos intermediários e a compilação final do analisador.

Com um Makefile bem configurado, todo o processo de construção do projeto pode ser realizado com apenas um comando:

```
make
```