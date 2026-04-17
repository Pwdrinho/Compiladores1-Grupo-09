# Padrões de Commit

## 1. Introdução

Os **padrões de commit** são convenções usadas para escrever mensagens de commit de forma **organizada e padronizada**.
Eles ajudam a manter o histórico do repositório claro e facilitam entender quais mudanças foram feitas no projeto.

Um dos padrões mais utilizados é o **Conventional Commits**.

## 2. Estrutura de um Commit

A estrutura básica de uma mensagem de commit é:

```
tipo/descrição curta da alteração ou descrição mais detalhada
```

Exemplo:
```
feat/adiciona analisador léxico com flex
```

## 3. Tipos de Commit

- **feat**

    Usado quando uma **nova funcionalidade** é adicionada.

    ```
    feat/adiciona suporte a operadores lógicos
    ```

---

- **fix**

    Usado quando um **erro é corrigido**.
    
    ```
    fix/corrige reconhecimento de identificadores
    ```

---

- **docs**

    Usado para alterações **apenas na documentação**.

    ```
    docs/adiciona manual do Makefile
    ```

---

- **style**

    Alterações que **não mudam o funcionamento do código**, como formatação ou identação.

    ```
    style/ajusta formatação do código
    ```

---

- **refactor**
    
    Usado quando o código é **reestruturado**, sem alterar seu comportamento.

    ```
    refactor/reorganiza regras do analisador léxico
    ```

---

- **test**

    Usado para alterações relacionadas a **testes**.

    ```
    test/adiciona novos arquivos de teste
    ```

---

- **chore**

    Usado para tarefas de **manutenção ou configuração do projeto**.

    ```
    chore/adiciona Makefile ao projeto
    ```


# 4. Escopo (Opcional)

É possível indicar qual parte do projeto foi alterada.

Estrutura:

```
tipo(escopo)/descrição
```

Exemplo 1:

```
feat(parser)/adiciona suporte a expressões aritméticas
```

Exemplo 2:

```
fix(lexer)/corrige reconhecimento de números
```
