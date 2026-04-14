# Palavras Reservadas da Linguagem C

## Introdução

As **palavras reservadas** (ou *keywords*) da linguagem C são termos com significado fixo e específico dentro da linguagem.

Essas palavras **não podem ser utilizadas como identificadores**, ou seja:

* nomes de variáveis
* nomes de funções
* nomes de tipos definidos pelo usuário

O padrão **ANSI C (C89/C90)** define um conjunto de **32 palavras reservadas**, apresentadas a seguir.

---

## Lista de Palavras Reservadas

| Palavra    | Descrição                                                                                     |
| ---------- | --------------------------------------------------------------------------------------------- |
| `auto`     | Classe de armazenamento padrão; variável local criada ao entrar na função e destruída ao sair |
| `break`    | Interrompe imediatamente loops (`for`, `while`, `do`) ou `switch`                             |
| `case`     | Define um caso dentro de um `switch`                                                          |
| `char`     | Tipo de dado para caracteres                                                                  |
| `const`    | Define um valor constante (imutável)                                                          |
| `continue` | Pula para a próxima iteração do loop                                                          |
| `default`  | Caso padrão dentro de um `switch`                                                             |
| `do`       | Estrutura de repetição executada ao menos uma vez (`do...while`)                              |
| `double`   | Tipo de dado de ponto flutuante de dupla precisão                                             |
| `else`     | Bloco executado quando o `if` é falso                                                         |
| `enum`     | Define um tipo enumerado                                                                      |
| `extern`   | Indica que a variável está definida em outro arquivo                                          |
| `float`    | Tipo de ponto flutuante de precisão simples                                                   |
| `for`      | Estrutura de repetição com contador                                                           |
| `goto`     | Salto incondicional no código                                                                 |
| `if`       | Estrutura condicional                                                                         |
| `int`      | Tipo de dado inteiro                                                                          |
| `long`     | Tipo inteiro com maior precisão                                                               |
| `register` | Sugere armazenamento em registradores da CPU                                                  |
| `return`   | Retorna um valor de uma função                                                                |
| `short`    | Tipo inteiro com menor precisão                                                               |
| `signed`   | Permite valores positivos e negativos                                                         |
| `sizeof`   | Retorna o tamanho em bytes de um tipo ou variável                                             |
| `static`   | Mantém valor da variável entre chamadas                                                       |
| `struct`   | Define uma estrutura (registro)                                                               |
| `switch`   | Estrutura de seleção múltipla                                                                 |
| `typedef`  | Cria novos nomes para tipos                                                                   |
| `union`    | Permite compartilhar memória entre variáveis                                                  |
| `unsigned` | Permite apenas valores positivos                                                              |
| `void`     | Indica ausência de tipo ou retorno                                                            |
| `volatile` | Indica que o valor pode mudar inesperadamente                                                 |
| `while`    | Estrutura de repetição baseada em condição                                                    |

---

## Observações

* Todas as palavras reservadas são escritas em **letras minúsculas**
* Não podem ser utilizadas como identificadores
* Esta lista corresponde ao padrão **ANSI C (C89/C90)**
* Algumas extensões (como `asm`) podem existir em compiladores específicos, mas não fazem parte do padrão ANSI

---

## Importância para o Compilador

No contexto do desenvolvimento de um compilador:

* Essas palavras devem ser reconhecidas como **tokens específicos**
* Não devem ser tratadas como identificadores
* Servem como base para o **analisador léxico (Flex)**

---

## Referência

* Padrão ANSI C (C89/C90)
