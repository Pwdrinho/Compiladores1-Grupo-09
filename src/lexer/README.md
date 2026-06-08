# Scanner (Analisador Léxico)

Este diretório contém a especificação do analisador léxico para o compilador, implementado utilizando Flex.

## Arquivos

- `scanner.l`: Arquivo de especificação Flex contendo as expressões regulares e ações para a tokenização da entrada.

## Requisitos

Para compilar e executar o scanner, você precisa de:
- **Flex** (Fast Lexical Analyzer Generator)
- **GCC** (GNU Compiler Collection)
- **Make** (opcional, para automação da compilação)

## Execução

### Opção 1: Usando o Makefile

A partir da raiz do projeto ou do diretório `src/lexer` (dependendo da localização do seu Makefile), execute:

```bash
# Para compilar o scanner
make

# Para executar o scanner com um arquivo de entrada
./scanner < arquivo_de_entrada.txt
```

### Opção 2: Compilação Manual

Se preferir compilar manualmente sem usar `make`, execute os seguintes comandos no terminal:

```bash
# 1. Gerar o código C a partir do arquivo Flex
flex scanner.l

# 2. Compilar o código C gerado em um executável
gcc lex.yy.c -o scanner -lfl

# 3. Executar o scanner
./scanner < arquivo_de_entrada.txt
```

*Observação:  Em alguns sistemas, pode ser necessário usar `-ll` em vez de `-lfl`, ou omitir essa flag caso você tenha definido `yywrap` no seu arquivo `.l`.*

## Testes
Para executar testes automatizados do scanner, consulte as instruções no arquivo `tests/README.md` na raiz do repositório.