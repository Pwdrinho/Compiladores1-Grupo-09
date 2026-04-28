# 1. Integração Léxico-Sintático

O **documento de integração** descreve como os *tokens* produzidos pelo analisador
léxico serão consumidos pelo analisador sintático (*parser*). Essa integração é o
ponto de contato entre as duas primeiras fases do compilador e define o contrato
formal pelo qual o léxico entrega informações estruturadas ao *parser*.

No modelo adotado por este projeto, o léxico é implementado com **Flex** e o
*parser* será implementado com **Bison** — ferramentas que se comunicam por meio
de uma interface padronizada: a função `yylex()`, a variável global `yylval` e o
arquivo de cabeçalho gerado pelo Bison (`parser.tab.h`).

---

## 1.1 Tabela Completa de Tokens

A tabela a seguir lista todos os tokens reconhecidos pelo analisador léxico
(`scanner.l`), seus códigos numéricos (iniciando em `258`, padrão Flex/Bison),
os padrões que os originam e o papel semântico que cada um cumpre no *parser*.

### 1.1.1 Palavras-Chave (`KW_*`)

| Token | Código | Lexema | Papel no Parser |
| --- | --- | --- | --- |
| `KW_AUTO` | 258 | `auto` | Especificador de classe de armazenamento |
| `KW_BREAK` | 259 | `break` | Instrução de desvio |
| `KW_CASE` | 260 | `case` | Rótulo de `switch` |
| `KW_CHAR` | 261 | `char` | Especificador de tipo |
| `KW_CONST` | 262 | `const` | Qualificador de tipo |
| `KW_CONTINUE` | 263 | `continue` | Instrução de desvio |
| `KW_DEFAULT` | 264 | `default` | Rótulo padrão de `switch` |
| `KW_DO` | 265 | `do` | Estrutura de repetição |
| `KW_DOUBLE` | 266 | `double` | Especificador de tipo |
| `KW_ELSE` | 267 | `else` | Ramificação condicional |
| `KW_ENUM` | 268 | `enum` | Declaração de enumeração |
| `KW_EXTERN` | 269 | `extern` | Especificador de armazenamento |
| `KW_FLOAT` | 270 | `float` | Especificador de tipo |
| `KW_FOR` | 271 | `for` | Estrutura de repetição |
| `KW_GOTO` | 272 | `goto` | Instrução de desvio incondicional |
| `KW_IF` | 273 | `if` | Estrutura condicional |
| `KW_INT` | 274 | `int` | Especificador de tipo |
| `KW_LONG` | 275 | `long` | Modificador de tipo |
| `KW_REGISTER` | 276 | `register` | Especificador de armazenamento |
| `KW_RETURN` | 277 | `return` | Instrução de retorno |
| `KW_SHORT` | 278 | `short` | Modificador de tipo |
| `KW_SIGNED` | 279 | `signed` | Modificador de tipo |
| `KW_SIZEOF` | 280 | `sizeof` | Operador de tamanho |
| `KW_STATIC` | 281 | `static` | Especificador de armazenamento |
| `KW_STRUCT` | 282 | `struct` | Declaração de estrutura |
| `KW_SWITCH` | 283 | `switch` | Estrutura de seleção |
| `KW_TYPEDEF` | 284 | `typedef` | Criação de alias de tipo |
| `KW_UNION` | 285 | `union` | Declaração de união |
| `KW_UNSIGNED` | 286 | `unsigned` | Modificador de tipo |
| `KW_VOID` | 287 | `void` | Especificador de tipo/retorno |
| `KW_VOLATILE` | 288 | `volatile` | Qualificador de tipo |
| `KW_WHILE` | 289 | `while` | Estrutura de repetição |

### 1.1.2 Identificadores e Literais

| Token | Código | Padrão | Carrega em `yylval` |
| --- | --- | --- | --- |
| `IDENT` | 290 | `[a-zA-Z_][a-zA-Z0-9_]*` | `sval` — cópia de `yytext` |
| `NUMBER` | 291 | `[0-9]+` | `ival` — valor convertido para inteiro |
| `NUMBER` | 291 | `[0-9]+\\.[0-9]+` | `dval` — valor convertido para double |

### 1.1.3 Operadores de Dois Caracteres (`TK_OP_*`)

| Token | Código | Lexema | Papel no Parser |
| --- | --- | --- | --- |
| `TK_OP_IGUAL_COMPARACAO` | 292 | `==` | Operador relacional de igualdade |
| `TK_OP_DIFERENTE` | 293 | `!=` | Operador relacional de diferença |
| `TK_OP_MENOR_IGUAL` | 294 | `<=` | Operador relacional |
| `TK_OP_MAIOR_IGUAL` | 295 | `>=` | Operador relacional |
| `TK_OP_AND` | 296 | `&&` | Operador lógico E |
| `TK_OP_OR` | 297 | `\|\|` | Operador lógico OU |
| `TK_OP_INCREMENTO` | 298 | `++` | Operador unário de incremento |
| `TK_OP_DECREMENTO` | 299 | `--` | Operador unário de decremento |
| `TK_OP_MAIS_IGUAL` | 300 | `+=` | Atribuição composta |
| `TK_OP_MENOS_IGUAL` | 301 | `-=` | Atribuição composta |
| `TK_OP_MULTIPLICACAO_IGUAL` | 302 | `*=` | Atribuição composta |
| `TK_OP_DIVISAO_IGUAL` | 303 | `/=` | Atribuição composta |
| `TK_OP_MODULO_IGUAL` | 304 | `%=` | Atribuição composta |
| `TK_OP_DESLOCAMENTO_ESQUERDA` | 305 | `<<` | Deslocamento de bits à esquerda |
| `TK_OP_DESLOCAMENTO_DIREITA` | 306 | `>>` | Deslocamento de bits à direita |
| `TK_OP_PONTEIRO_ACESSO` | 307 | `->` | Acesso a membro via ponteiro |

### 1.1.4 Operadores de Um Caractere e Delimitadores

| Token | Código | Lexema | Papel no Parser |
| --- | --- | --- | --- |
| `TK_OP_SOMA` | 308 | `+` | Operador aritmético / unário |
| `TK_OP_SUBTRACAO` | 309 | `-` | Operador aritmético / unário |
| `TK_OP_MULTIPLICACAO` | 310 | `*` | Operador aritmético / ponteiro |
| `TK_OP_DIVISAO` | 311 | `/` | Operador aritmético |
| `TK_OP_MODULO` | 312 | `%` | Operador aritmético |
| `TK_OP_IGUAL` | 313 | `=` | Operador de atribuição |
| `TK_OP_MENOR` | 314 | `<` | Operador relacional |
| `TK_OP_MAIOR` | 315 | `>` | Operador relacional |
| `TK_OP_NAO` | 316 | `!` | Operador lógico de negação |
| `TK_OP_E_BIT` | 317 | `&` | Bit a bit E / endereço |
| `TK_OP_OU_BIT` | 318 | `\|` | Bit a bit OU |
| `TK_OP_XOR_BIT` | 319 | `^` | Bit a bit XOR |
| `TK_OP_NOT_BIT` | 320 | `~` | Bit a bit complemento |
| `TK_OP_TERNARIO` | 321 | `?` | Operador ternário (parte 1) |
| `TK_OP_DOIS_PONTOS` | 322 | `:` | Operador ternário / rótulo |
| `TK_OP_PONTO` | 323 | `.` | Acesso a membro de struct |
| `TK_OP_VIRGULA` | 324 | `,` | Separador de argumentos |
| `TK_OP_PONTO_VIRGULA` | 325 | `;` | Terminador de instrução |
| `TK_ABRE_PARENTESE` | 326 | `(` | Agrupamento / chamada |
| `TK_FECHA_PARENTESE` | 327 | `)` | Agrupamento / chamada |
| `TK_ABRE_CHAVE` | 328 | `{` | Início de bloco |
| `TK_FECHA_CHAVE` | 329 | `}` | Fim de bloco |
| `TK_ABRE_COLCHETE` | 330 | `[` | Acesso a array |
| `TK_FECHA_COLCHETE` | 331 | `]` | Acesso a array |

---

## 1.2 A Interface `yylex()` — Como o Parser Consome Tokens

No modelo Flex/Bison, o *parser* não lê o código-fonte diretamente. Em vez disso,
ele invoca repetidamente a função `yylex()`, gerada pelo Flex, que:

1. Avança o cursor de leitura sobre o arquivo-fonte;
2. Reconhece o próximo *lexema* com base nas regras do `scanner.l`;
3. Preenche a variável global `yylval` com o valor semântico do token;
4. Retorna o **código numérico** do token reconhecido.

O fluxo pode ser representado da seguinte forma:

| Fase / Componente | Ação Principal | O que é transmitido? |
| --- | --- | --- |
| **1. Arquivo `.c`** | Fornece o código-fonte bruto. | Fluxo de caracteres (texto). |
| **2. `yylex()`** *(Léxico)* | Lê o texto, identifica padrões e gera tokens. | **Código do Token:** ex: `IDENT = 290`<br>**Valor Semântico:** ex: `yylval.sval = "total"` |
| **3. Parser** *(Sintático)* | Consome a saída do léxico para validar a gramática. | **Decisão:** Usa o código numérico.<br>**Árvore (AST):** Usa o conteúdo de `yylval`. |

---

## 1.3 Estrutura de Valores — `yylval`

A variável `yylval` é o mecanismo pelo qual o léxico transmite o **valor semântico**
de cada token ao *parser*. Ela é declarada como uma `union` no arquivo Bison, de
modo que cada campo corresponde a um tipo de dado que um token pode carregar.

### 1.3.1 Declaração da Union

```c
%union {
    char*  sval;   /* valor textual: usado por IDENT */
    int    ival;   /* valor inteiro: usado por NUMBER inteiro */
    double dval;   /* valor real: usado por NUMBER com ponto flutuante */
}
```

### 1.3.2 Associação Token → Campo da Union

| Token | Campo usado | Como é preenchido no scanner |
| --- | --- | --- |
| `IDENT` | `sval` | `yylval.sval = strdup(yytext);` |
| `NUMBER` (inteiro) | `ival` | `yylval.ival = atoi(yytext);` |
| `NUMBER` (ponto flutuante) | `dval` | `yylval.dval = atof(yytext);` |
| Palavras-chave e operadores | — | Não carregam valor; o código do token já é suficiente |

### 1.3.3 Proposta de Modificação do Scanner

Para habilitar a integração com o Bison, as regras de `IDENT` e `NUMBER` no
`scanner.l` deverão ser modificadas conforme abaixo:

```c
/* Antes (versão atual — apenas imprime) */
[a-zA-Z_][a-zA-Z0-9_]* {
    printf("IDENT(%s)\\n", yytext);
    return IDENT;
}

[0-9]+(\\.[0-9]+)? {
    printf("NUMBER(%s)\\n", yytext);
    return NUMBER;
}

/* Depois (versão integrada com Bison) */
[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.sval = strdup(yytext);
    return IDENT;
}

/* Regra para números decimais (float/double) */
[0-9]+\.[0-9]+ {
    yylval.dval = atof(yytext);
    return NUMBER;
}

/* Regra para números inteiros */
[0-9]+ {
    yylval.ival = atoi(yytext);
    return NUMBER;
}
```

> **Observação:** O `strdup` aloca uma cópia do lexema na heap. O *parser* é
responsável por liberar essa memória após o uso, evitando vazamentos.
> 

---

## 1.4 Exemplos de Entrada e Fluxo de Tokens

Os exemplos a seguir são extraídos diretamente dos testes automatizados do
projeto (`scanner/inputs/`), garantindo correspondência exata com o comportamento
real do `scanner.l`.

---

### 1.4.1 Identificadores e Literais Numéricos (`02_identifiers_numbers.in`)

**Entrada:**

```c
_tmp var1 intx 0 42 3.14 10.
```

**Sequência de tokens produzida:**

| Lexema | Token | `yylval` |
| --- | --- | --- |
| `_tmp` | `IDENT` (290) | `sval = "_tmp"` |
| `var1` | `IDENT` (290) | `sval = "var1"` |
| `intx` | `IDENT` (290) | `sval = "intx"` |
| `0` | `NUMBER` (291) | `ival = 0` |
| `42` | `NUMBER` (291) | `ival = 42` |
| `3.14` | `NUMBER` (291) | `dval = 3.14` |
| `10.` | `NUMBER` (291) | `ival = 10` + `TK_OP_PONTO` |

> **Nota:** O lexema `intx` é reconhecido como `IDENT` e **não** como a
palavra-chave `int`, pois o padrão de keywords exige correspondência exata
do lexema completo. O caso `10.` demonstra que o ponto flutuante exige ao
menos um dígito após o `.`; o scanner tokeniza como `NUMBER(10)` seguido de
`TK_OP_PONTO`.
> 

---

### 1.4.2 Comentários e Espaços em Branco (`05_comments_whitespace.in`)

**Entrada:**

```c
// this line is a comment
int value /* ignored block comment */ = 12;
```

**Sequência de tokens produzida:**

| Lexema | Token | `yylval` |
| --- | --- | --- |
| `// this line is a comment` | *(descartado)* | — |
| `int` | `KW_INT` (274) | — |
| `value` | `IDENT` (290) | `sval = "value"` |
| `/* ignored block comment */` | *(descartado)* | — |
| `=` | `TK_OP_IGUAL` (313) | — |
| `12` | `NUMBER` (291) | `ival = 12` |
| `;` | `TK_OP_PONTO_VIRGULA` (325) | — |

> **Nota:** Comentários de linha (`//`) e de bloco (`/* */`) são consumidos
pelo léxico mas não geram nenhum token para o *parser*. O espaço em branco
entre tokens também é descartado silenciosamente.
> 

---

### 1.4.3 Trecho Misto — Programa Completo (`07_mixed_snippet.in`)

Este caso de teste é o mais abrangente da suíte, combinando declaração de
função, declaração de variável com inicialização, atribuição composta,
estrutura condicional e operadores de dois caracteres.

**Entrada:**

```c
int main() {
    int a = 10;
    a += 2;
    if (a >= 12 && a != 0) {
        a--;
    }
}
```

**Sequência de tokens produzida:**

| Lexema | Token | `yylval` |
| --- | --- | --- |
| `int` | `KW_INT` (274) | — |
| `main` | `IDENT` (290) | `sval = "main"` |
| `(` | `TK_ABRE_PARENTESE` (326) | — |
| `)` | `TK_FECHA_PARENTESE` (327) | — |
| `{` | `TK_ABRE_CHAVE` (328) | — |
| `int` | `KW_INT` (274) | — |
| `a` | `IDENT` (290) | `sval = "a"` |
| `=` | `TK_OP_IGUAL` (313) | — |
| `10` | `NUMBER` (291) | `ival = 10` |
| `;` | `TK_OP_PONTO_VIRGULA` (325) | — |
| `a` | `IDENT` (290) | `sval = "a"` |
| `+=` | `TK_OP_MAIS_IGUAL` (300) | — |
| `2` | `NUMBER` (291) | `ival = 2` |
| `;` | `TK_OP_PONTO_VIRGULA` (325) | — |
| `if` | `KW_IF` (273) | — |
| `(` | `TK_ABRE_PARENTESE` (326) | — |
| `a` | `IDENT` (290) | `sval = "a"` |
| `>=` | `TK_OP_MAIOR_IGUAL` (295) | — |
| `12` | `NUMBER` (291) | `ival = 12` |
| `&&` | `TK_OP_AND` (296) | — |
| `a` | `IDENT` (290) | `sval = "a"` |
| `!=` | `TK_OP_DIFERENTE` (293) | — |
| `0` | `NUMBER` (291) | `ival = 0` |
| `)` | `TK_FECHA_PARENTESE` (327) | — |
| `{` | `TK_ABRE_CHAVE` (328) | — |
| `a` | `IDENT` (290) | `sval = "a"` |
| `--` | `TK_OP_DECREMENTO` (299) | — |
| `;` | `TK_OP_PONTO_VIRGULA` (325) | — |
| `}` | `TK_FECHA_CHAVE` (329) | — |
| `}` | `TK_FECHA_CHAVE` (329) | — |

---

## 1.5 Tokens Ignorados pelo Parser

Os padrões a seguir são consumidos pelo léxico mas **não geram tokens** para o
*parser*, pois não possuem relevância gramatical:

| Padrão | Tratamento |
| --- | --- |
| `[ \\t\\n]+` | Espaços, tabulações e quebras de linha — descartados silenciosamente |
| `// ...` | Comentário de linha — descartado |
| `/* ... */` | Comentário de bloco — descartado |
| `.` (caractere desconhecido) | Emite `UNKNOWN` no terminal; não retorna token válido ao *parser* |