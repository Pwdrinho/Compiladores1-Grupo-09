# Compiladores 1 Grupo 09

Documentação do projeto que implementa um **tradutor de um subconjunto de C para Go** para a disciplina de Compiladores 1, ministrada pelo professor **Dr. Sérgio Antônio** no semestre de **2026.1** da **FCTE/UnB**.

## Objetivo

O projeto demonstra as principais fases de um compilador:

- análise léxica com Flex;
- análise sintática com Bison;
- construção de AST;
- tabela de símbolos e validações semânticas básicas;
- geração de código intermediário estruturado;
- geração de código Go final a partir do intermediário.

## Escopo atual

O compilador suporta funções simples, variáveis, expressões aritméticas e relacionais,
`if`/`else`, `while`, `for`, `return`, incremento/decremento e chamadas simples de função.
Também valida assinaturas de funções, quantidade de argumentos e compatibilidade
básica de retornos.

O foco é a tradução correta de um subconjunto pequeno e demonstrável, não a cobertura completa da linguagem C.

## Comandos principais

```bash
make all
make test
make codegen-test
./compilador_grupo09.sh arquivo.c
```
