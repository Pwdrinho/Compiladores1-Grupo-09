# Guia de Build: Processamento e Compilação (.l e .y)

Este manual descreve o fluxo de trabalho para transformar definições léxicas (Flex) e gramáticas sintáticas (Bison) em um programa executável.

## O que acontece nos bastidores?
Diferente de um código comum, arquivos `.l` e `.y` passam por um processo de **Geração de Código**:
1. O **Bison** processa o `.y` e gera um analisador sintático em C.
2. O **Flex** processa o `.l` e gera um analisador léxico em C.
3. O **GCC** compila os arquivos C gerados em um único executável.

## Passo a Passo (Comandos)

### 1. Gerar o Analisador Sintático (Bison)
Primeiro, processe a gramática para gerar as definições de tokens que o Flex precisará.
```bash
bison -d arquivo.y
```

- Gera: **arquivo.tab.c** e **arquivo.tab.h**.
- A flag **-d** é essencial para criar o cabeçalho (*.h*).

### 2. Gerar o Analisador Léxico (Flex)
Agora, transforme suas expressões regulares em código C.
```bash
flex arquivo.l
```

- Gera: lex.yy.c.

### 3. Compilação Final (GCC)
Combine os códigos gerados e compile o programa final.
```bash
gcc lex.yy.c arquivo.tab.c -o meu_analisador -lfl
```

- *-o meu_analisador*: Nome do seu programa executável.
- *-lfl*: Biblioteca necessária para o funcionamento do Flex.

### 4. Executar
Após a compilação final é gerado um executável que pode ser executado dessa maneira:
```bash
./meu_analisador
```

### 5. Executar com arquivo de teste
No mesmo esquema da execução, para executar junto com um arquivo teste faça assim:
```bash
./meu_analisador < teste.c
```