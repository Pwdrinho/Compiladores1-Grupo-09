# 1. Introdução 

O **analisador léxico** (também chamado de *lexer* ou *scanner*) é a fase inicial de um compilador. É um componente que realiza uma **análise linear** da entrada, ou seja, ele lê o fluxo amorfo de caracteres de um programa fonte e agrupa esses caracteres em sequências com significados gramaticais chamados ***Lexemas***. Para cada lexema, o analisador produz um ***Token*** como saída para o analisador sintático.

Ao separar o código fonte em tokens, o analisador léxico simplifica o trabalho das fases posteriores do compilador, permitindo que o analisador sintático trabalhe com unidades mais estruturadas ao invés de lidar diretamente com caracteres individuais.

## 1.1 Conceitos Fundamentais:

Entre os principais conceitos utilizados estão ***lexemas*, *tokens*, *padrões*, *expressões regulares*, *linguagens regulares* e *autômatos finitos***.

1.  **Lexema**: A sequência de caracteres concreta encontrada no código-fonte. 
```bash
`total`, `123`, `+`, `int`
```

2.  **Token**: Uma categoria gramatical abstrata de um *lexema* reconhecida pelo analisador léxico, podendo ser considerada a menor unidade sintática com significado. Formalmente, um token pode ser representado como um par:
```bash
(token_type, atributo)
(NUMBER, 10)
```
Onde:
- **token_type** representa a categoria do token
- **atributo** contém informações adicionais sobre o token

3.  **Padrão (Pattern)**: Define a regra formal que descreve como os tokens devem ser formados, geralmente especificados por meio de **Expressões Regulares**.
```bash
IDENTIFIER → letter (letter | digit)*
NUMBER → digit+
```

4. **Expressões Regulares (Regex)**: São notações formais utilizadas para descrever padrões de cadeias de caracteres, permitindo especificar como os token de uma *linguagem regulares* podem ser reconhecidos.
```bash
digit → [0-9]
letter → [a-z A-Z]
identifier → letter (letter | digit)*
```
Cada expressão regular define um conjunto de cadeias válidas pertencentes a um determinado tipo de token.

5. **Linguagens Regulares**: Cada padrão definido por uma expressão regular corresponde a uma *linguagem regular*, ou seja, um conjunto de cadeias de caracteres que seguem determinadas regras.

As linguagens regulares possuem propriedades matemáticas bem definidas e podem ser reconhecidas por ***autômatos finitos***.

6. **Autômatos Finitos**: São *modelos matemáticos* utilizados para reconhecer linguagens regulares. Eles funcionam como máquinas de estados que realizam transições entre estados conforme os caracteres do código fonte são lidos.

Na implementação de analisadores léxicos, os padrões definidos por expressões regulares são geralmente convertidos em **autômatos finitos determinísticos (DFA)**, que permitem reconhecer tokens de forma eficiente.
O processo teórico pode ser representado da seguinte forma:
```bash
Expressão Regular
        ↓
Autômato Finito Não Determinístico (NFA)
        ↓
Autômato Finito Determinístico (DFA)
        ↓
Implementação do Analisador Léxico
```