# 1. Especificação da Gramática da Linguagem

A gramática formal define as **regras sintáticas** que determinam como os tokens
produzidos pelo analisador léxico podem ser combinados para formar construções
válidas da linguagem C. Esta especificação serve como base para a implementação
do analisador sintático e como referência para a resolução de ambiguidades.

A notação adotada é a **EBNF (Extended Backus-Naur Form)**, escolhida por sua
legibilidade e capacidade de expressar repetição e opcionalidade de forma compacta.

A especificação está organizada em duas partes. A **Seção 2** documenta a gramática
atualmente implementada no `parser.y`, refletindo o estado validado do analisador
sintático. A **Seção 3** documenta a especificação completa da linguagem alvo —
todos os tokens reconhecidos pelo léxico e as construções que o compilador suportará
ao final do desenvolvimento.

---

## 1.1 Convenções da Notação EBNF

| Notação       | Significado                                   |
|---------------|-----------------------------------------------|
| `A ::= B`     | A é definido como B                           |
| `A B`         | A seguido de B (concatenação)                 |
| `A \| B`      | A ou B (alternativa)                          |
| `[ A ]`       | A é opcional (zero ou uma vez)                |
| `{ A }`       | A se repete zero ou mais vezes                |
| `( A )`       | Agrupamento                                   |
| `'token'`     | Terminal literal                              |
| `TOKEN`       | Terminal nomeado (retornado pelo léxico)       |

---

# 2. Estado Atual da Implementação

Esta seção descreve as regras gramaticais atualmente implementadas no analisador
sintático. Toda construção aqui documentada possui regra ativa no `parser.y` e
pode ser validada pelo compilador.

---

## 2.1 Estrutura do Programa

O ponto de entrada da gramática é `programa`. Um arquivo-fonte válido é composto
por uma sequência de elementos. Atualmente, um elemento pode ser uma função ou
uma declaração global simples.

```ebnf
programa ::= lista_elementos

lista_elementos ::= lista_elementos elemento
                  | elemento

elemento ::= funcao
           | declaracao
```

---

## 2.2 Tipos

O parser reconhece os seguintes tipos primitivos:

```ebnf
tipo ::= 'int'
       | 'float'
       | 'void'
```

---

## 2.3 Funções

Uma função é formada por um tipo de retorno, um nome, uma lista de parâmetros
entre parênteses e um bloco de comandos.

```ebnf
funcao ::= tipo IDENT '(' parametros ')' bloco

parametros ::= lista_parametros
             | /* vazio */

lista_parametros ::= lista_parametros ',' parametro
                   | parametro

parametro ::= tipo IDENT
```

Exemplos válidos:

```c
int soma(int a, int b) { ... }
void imprime() { ... }
```

---

## 2.4 Bloco e Lista de Comandos

Um bloco agrupa zero ou mais comandos entre chaves. É a unidade estrutural
utilizada nos corpos de funções e nas estruturas de controle.

```ebnf
bloco ::= '{' lista_comandos '}'

lista_comandos ::= lista_comandos comando
                 | /* vazio */
```

---

## 2.5 Comandos

Um comando é a unidade de execução do programa. O parser reconhece os seguintes
tipos de comando:

```ebnf
comando ::= declaracao
          | atribuicao
          | retorno
          | comando_if
          | comando_while
          | comando_for
          | incremento
          | chamada_funcao ';'
          | bloco
```

### 2.5.1 Declaração de Variável

```ebnf
declaracao ::= tipo IDENT ';'
             | tipo IDENT '=' expressao ';'
             | tipo IDENT '[' NUMBER ']' ';'
```

Exemplos válidos:

```c
int x;
float y = 3.14;
int v[10];
```

### 2.5.2 Atribuição

Em comandos gerais, apenas a atribuição simples está implementada:

```ebnf
atribuicao ::= IDENT '=' expressao ';'
```

### 2.5.3 Incremento e Decremento

Aceita as formas pré-fixada e pós-fixada como comandos isolados:

```ebnf
incremento ::= IDENT '++' ';'
             | IDENT '--' ';'
             | '++' IDENT ';'
             | '--' IDENT ';'
```

### 2.5.4 Retorno

```ebnf
retorno ::= 'return' expressao ';'
          | 'return' ';'
```

### 2.5.5 Condicional — `if / else`

O corpo do `if` e do `else` exige obrigatoriamente um bloco com chaves.
A ambiguidade do *dangling else* é resolvida via `%prec LOWER_THAN_ELSE`,
associando o `else` sempre ao `if` mais interno.

```ebnf
comando_if ::= 'if' '(' expressao_booleana ')' bloco
             | 'if' '(' expressao_booleana ')' bloco 'else' bloco
```

### 2.5.6 Repetição — `while`

```ebnf
comando_while ::= 'while' '(' expressao_booleana ')' bloco
```

### 2.5.7 Repetição — `for`

As três partes do `for` são independentes e opcionais:

```ebnf
comando_for ::= 'for' '(' for_init ';' for_condicao ';' for_atualizacao ')' bloco

for_init ::= declaracao_for
           | atribuicao_for
           | /* vazio */

for_condicao ::= expressao_booleana
               | /* vazio */

for_atualizacao ::= atribuicao_for
                  | incremento_for
                  | /* vazio */

declaracao_for ::= tipo IDENT
                 | tipo IDENT '=' expressao

atribuicao_for ::= IDENT '=' expressao
                 | IDENT '+=' expressao
                 | IDENT '-=' expressao

incremento_for ::= IDENT '++'
                 | IDENT '--'
                 | '++' IDENT
                 | '--' IDENT
```

Exemplos válidos:

```c
for (int i = 0; i < 10; i++) { ... }
for (i = 0; i != n; i += 2) { ... }
for ( ; ; ) { ... }
```

### 2.5.8 Chamada de Função como Comando

Chamadas simples de função podem aparecer como comando isolado:

```ebnf
chamada_funcao ::= IDENT '(' argumentos ')'

argumentos ::= lista_argumentos
             | /* vazio */

lista_argumentos ::= lista_argumentos ',' expressao
                   | expressao
```

Exemplos válidos:

```c
foo();
soma(1, 2);
```

---

## 2.6 Expressões

### 2.6.1 Expressão Booleana

Utilizada nas condições de `if`, `while` e `for`. Aceita comparações simples,
combinadas com `&&` e `||`, e agrupadas com parênteses:

```ebnf
expressao_booleana ::= expressao operador_relacional expressao
                     | expressao_booleana '&&' expressao_booleana
                     | expressao_booleana '||' expressao_booleana
                     | '(' expressao_booleana ')'

operador_relacional ::= '<' | '>' | '<=' | '>=' | '==' | '!='
```

### 2.6.2 Expressão Aritmética

A hierarquia em três níveis garante a precedência correta entre os operadores.
Operadores de maior precedência estão em níveis mais profundos da gramática,
garantindo que `2 + 3 * 4` seja interpretado como `2 + (3 * 4)`:

```ebnf
expressao ::= expressao '+' termo
            | expressao '-' termo
            | termo

termo ::= termo '*' fator
        | termo '/' fator
        | termo '%' fator
        | fator

fator ::= NUMBER
        | IDENT
        | acesso_vetor
        | chamada_funcao
        | '(' expressao ')'
```

### 2.6.3 Acesso a Vetor

```ebnf
acesso_vetor ::= IDENT '[' expressao ']'
```

### 2.6.4 Chamada de Função em Expressão

Chamadas simples de função também são aceitas como fator de expressão, permitindo
atribuições como:

```c
int r = soma(2, 3);
```

---

## 2.7 Tabela de Precedência

A tabela reflete exatamente as declarações `%left`, `%right` e `%nonassoc`
presentes no `parser.y`, do menor para o maior nível:

| Nível | Operadores                                 | Associatividade   |
|-------|--------------------------------------------|-------------------|
| 1     | `\|\|`                                     | Esquerda          |
| 2     | `&&`                                       | Esquerda          |
| 3     | `==` `!=`                                  | Esquerda          |
| 4     | `<` `>` `<=` `>=`                          | Esquerda          |
| 5     | `+` `-`                                    | Esquerda          |
| 6     | `*` `/` `%`                                | Esquerda          |
| 7     | `!` (unário)                               | Direita           |
| 8     | `=` (atribuição)                           | Direita           |
| 9     | `else` (via `LOWER_THAN_ELSE` / `KW_ELSE`) | Não-associativo   |

---

## 2.8 Ambiguidades Conhecidas e Resoluções

### 2.8.1 Dangling Else

Dado um `if` aninhado sem `else`, o parser precisa decidir a qual `if` o
`else` pertence:

```c
if (a)
    if (b)
        x = 1;
    else      /* pertence ao if (b), não ao if (a) */
        x = 2;
```

**Solução adotada:** o `else` é sempre associado ao `if` mais interno.
Implementada no Bison declarando `KW_ELSE` com maior precedência que
`LOWER_THAN_ELSE`:

```
%nonassoc LOWER_THAN_ELSE
%nonassoc KW_ELSE
```

### 2.8.2 `typedef-name` vs `IDENT`

Nomes criados com `typedef` podem aparecer em posições de tipo, criando
ambiguidade com identificadores comuns:

```c
typedef int Inteiro;
Inteiro x;   /* "Inteiro" é um tipo ou um identificador? */
```

O parser não consegue distinguir os dois casos apenas com a gramática — a
decisão depende de saber se `Inteiro` foi previamente declarado como `typedef`.

**Solução adotada:** `typedef` está fora do subconjunto atual. A resolução
completa exigiria uma tabela de símbolos específica para nomes de tipos, mas o
parser hoje aceita apenas `int`, `float` e `void` na regra `tipo`.

---

# 3. Especificação da Linguagem Alvo

Esta seção define o escopo completo da linguagem que o compilador suportará.
As construções aqui descritas têm seus tokens já reconhecidos pelo léxico e
declarados no parser, e serão integradas ao `parser.y` nas próximas iterações
do desenvolvimento.

---

## 3.1 Tipos

### 3.1.1 Tipos Primitivos Completos

A regra `tipo` será expandida para cobrir todos os primitivos do padrão ANSI C:

```ebnf
tipo ::= 'int'    | 'float'  | 'void'
       | 'char'   | 'double' | 'long'
       | 'short'  | 'signed' | 'unsigned'
```

### 3.1.2 Especificadores de Armazenamento

```ebnf
especificador_armazenamento ::= 'auto'
                              | 'extern'
                              | 'register'
                              | 'static'
```

### 3.1.3 Qualificadores de Tipo

```ebnf
qualificador_tipo ::= 'const'
                    | 'volatile'
```

---

## 3.2 Comandos

### 3.2.1 Atribuições Compostas

A regra `atribuicao` será expandida para cobrir todos os operadores compostos
fora do contexto do `for`:

```ebnf
atribuicao ::= IDENT '=' expressao ';'
             | IDENT '+=' expressao ';'
             | IDENT '-=' expressao ';'
             | IDENT '*=' expressao ';'
             | IDENT '/=' expressao ';'
             | IDENT '%=' expressao ';'
```

### 3.2.2 `do...while`

```ebnf
comando_do_while ::= 'do' bloco 'while' '(' expressao_booleana ')' ';'
```

### 3.2.3 `switch`

```ebnf
comando_switch ::= 'switch' '(' expressao ')' '{' { clausula_case } '}'

clausula_case ::= 'case' expressao_constante ':' { comando }
               | 'default' ':' { comando }

expressao_constante ::= NUMBER | IDENT
```

### 3.2.4 Desvios

```ebnf
comando_break    ::= 'break' ';'
comando_continue ::= 'continue' ';'
comando_goto     ::= 'goto' IDENT ';'
comando_rotulo   ::= IDENT ':' comando
```

---

## 3.3 Tipos Compostos

### 3.3.1 Struct

```ebnf
especificador_struct ::= 'struct' IDENT '{' { membro_struct } '}'
                       | 'struct' IDENT

membro_struct ::= tipo lista_membros ';'

lista_membros ::= IDENT { ',' IDENT }
```

### 3.3.2 Union

```ebnf
especificador_union ::= 'union' IDENT '{' { membro_struct } '}'
                      | 'union' IDENT
```

### 3.3.3 Enum

```ebnf
especificador_enum ::= 'enum' IDENT '{' lista_enumeradores '}'
                     | 'enum' IDENT

lista_enumeradores ::= enumerador { ',' enumerador }

enumerador ::= IDENT
             | IDENT '=' expressao_constante
```

### 3.3.4 Typedef

```ebnf
declaracao_typedef ::= 'typedef' tipo IDENT ';'
                     | 'typedef' especificador_struct IDENT ';'
                     | 'typedef' especificador_union IDENT ';'
                     | 'typedef' especificador_enum IDENT ';'
```

---

## 3.4 Expressões

### 3.4.1 Operadores Unários

```ebnf
expressao_unaria ::= '!' expressao_unaria
                   | '~' expressao_unaria
                   | '-' expressao_unaria
                   | '+' expressao_unaria
                   | '++' IDENT
                   | '--' IDENT
                   | 'sizeof' '(' tipo ')'
                   | 'sizeof' '(' IDENT ')'
```

### 3.4.2 Operadores Bit a Bit e Deslocamento

```ebnf
expressao_bit ::= expressao '&' expressao
                | expressao '|' expressao
                | expressao '^' expressao
                | '~' expressao

expressao_deslocamento ::= expressao '<<' expressao
                         | expressao '>>' expressao
```

### 3.4.3 Operador Ternário

```ebnf
expressao_ternaria ::= expressao_booleana '?' expressao ':' expressao
```

### 3.4.4 Acesso a Membros

```ebnf
acesso_membro ::= IDENT '.' IDENT
               | IDENT '->' IDENT
```

---

## 3.5 Tabela de Precedência Completa

Expansão da tabela atual incorporando todos os operadores da linguagem alvo,
do menor para o maior nível:

| Nível | Operadores                                      | Associatividade   |
|-------|-------------------------------------------------|-------------------|
| 1     | `\|\|`                                          | Esquerda          |
| 2     | `&&`                                            | Esquerda          |
| 3     | `\|`                                            | Esquerda          |
| 4     | `^`                                             | Esquerda          |
| 5     | `&`                                             | Esquerda          |
| 6     | `==` `!=`                                       | Esquerda          |
| 7     | `<` `>` `<=` `>=`                               | Esquerda          |
| 8     | `<<` `>>`                                       | Esquerda          |
| 9     | `+` `-`                                         | Esquerda          |
| 10    | `*` `/` `%`                                     | Esquerda          |
| 11    | `!` `~` `-` `+` (unários)                       | Direita           |
| 12    | `=` `+=` `-=` `*=` `/=` `%=`                    | Direita           |
| 13    | `?` `:` (ternário)                              | Direita           |
| 14    | `else` (via `LOWER_THAN_ELSE` / `KW_ELSE`)      | Não-associativo   |
