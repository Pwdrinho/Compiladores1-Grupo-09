# Testes do Léxico

Os testes do léxico foram feito com base em arquivos de entrada(.c) e saídas esperadas(.out) com suit de automação com MAKEFILE.

## Estrutura de Testes

A metodologia de testes consiste em comparar a saída gerada pelo analisador léxico com uma saída de referência (gabarito). Para cada caso de teste, existe um arquivo `.c` (entrada) e um arquivo `.out` (saída esperada).

### Automação com Makefile

O processo de compilação e execução dos testes é automatizado via `Makefile`, permitindo a execução em lote e a verificação rápida de regressões. Os principais comandos são:

- `make`: Compila o analisador léxico utilizando o Flex e o GCC.
- `make test`: Executa o analisador para todos os arquivos na pasta de testes e compara os resultados utilizando o comando `diff`.
- `make clean`: Remove os arquivos temporários e o executável gerado.
adicionar mais partes do make

## Casos de Teste Cobertos

Os testes foram projetados para validar o reconhecimento de todas as classes de tokens definidas na especificação:

1.  **Palavras Reservadas**: Validação de todas as 32 palavras do padrão ANSI C (ex: `int`, `return`, `if`, `while`).
2.  **Identificadores**: Nomes de variáveis válidos, incluindo o uso de underscores e distinção entre maiúsculas e minúsculas.
3.  **Literais Numéricos**: Inteiros e constantes de ponto flutuante.
4.  **Operadores e Delimitadores**: Reconhecimento de símbolos simples (`+`, `-`, `*`) e compostos (`==`, `!=`, `<=`).
5.  **Comentários**: Verificação de que comentários de linha (`//`) e de bloco (`/* ... */`) são corretamente ignorados pelo lexer.
6.  **Tratamento de Erros**: Verificação da reação do analisador diante de caracteres inválidos ou lexemas mal formados.
verificar essa parte

## Carater dos testes
bloco de testes atômicos que são os mais essenciais responsáveis por cobrir quase todas as linhas
Bloco de Contexto e Erros; reage quando um comentário em bloco é aberto, mas o arquivo termina sem que ele seja fechado. Fundamental para testar a resiliência do algoritmo; Inclui símbolos inválidos na linguagem C (como @ ou $). Ele foi o responsável por testar a regra residual . (fallback) na linha 156 do seu arquivo, garantindo que o compilador capture caracteres desconhecidos. ; Contém comentários de linha (//) e blocos com comentários multilinha (/* ... */). Ele garantiu que as expressões de descarte de comentários do Flex funcionassem sem gerar tokens espúrios.
bloco de códigos estruturados Eles não aumentam a cobertura do Lexer porque o Lexer não enxerga a estrutura do programa, apenas lê caracteres individualmente. Essencias para parser mas não se aplicam tão bem para o léxico.

## Cobertura de testes gerados com Gcov e gerado de maneira visual em html

## intruções de como executar 
Makefile além de automatizar ele dá as instruções de cada código de teste individualmente