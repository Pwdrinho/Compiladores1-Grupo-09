
## 2. Fundamentação Teórica 

O analisador léxico fundamenta-se em princípios da *teoria de linguagens formais* e da *teoria da computação*, que fornecem os **mecanismos matemáticos** necessários para a **definição e reconhecimento dos padrões** presentes em uma linguagem de programação. Esses fundamentos permitem descrever formalmente os elementos léxicos da linguagem e implementar mecanismos eficientes para sua identificação no código fonte.

A base teórica para a construção de analisadores léxicos está principalmente relacionada às **linguagens regulares**, **expressões regulares** e **autômatos finitos**, que constituem modelos formais capazes de representar e reconhecer padrões de cadeias de caracteres.

As **linguagens regulares** representam uma classe de linguagens formais que podem ser descritas por *expressões regulares* e reconhecidas por *autômatos finitos*. Essas linguagens possuem propriedades matemáticas bem definidas e são particularmente adequadas para descrever os padrões léxicos de linguagens de programação, como identificadores, números, operadores e delimitadores.

As expressões regulares são utilizadas como uma forma declarativa de especificar os padrões que definem os tokens da linguagem. Por meio dessa notação, é possível representar conjuntos de cadeias válidas de forma compacta e precisa. Dessa forma, cada tipo de token pode ser associado a uma expressão regular que descreve sua estrutura.

A partir dessas expressões, é possível construir autômatos finitos capazes de reconhecer os padrões especificados. Inicialmente, as expressões regulares podem ser convertidas em **autômatos finitos não determinísticos (NFA)**, que posteriormente são transformados em **autômatos finitos determinísticos (DFA)** equivalentes. Esse processo de transformação permite a obtenção de um modelo computacional eficiente para a implementação do analisador léxico.

O **DFA** resultante pode ser utilizado para processar o código fonte caractere por caractere, realizando transições entre estados até identificar a ocorrência de um padrão correspondente a um token da linguagem. Essa abordagem garante que o reconhecimento léxico seja realizado de maneira sistemática e eficiente.