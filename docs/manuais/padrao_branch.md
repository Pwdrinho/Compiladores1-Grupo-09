# Padrões de Branch

## 1. Introdução

Os **padrões de branch** são convenções usadas para **nomear e organizar as ramificações de um repositório Git**.
Eles ajudam a manter o desenvolvimento organizado e facilitam a identificação do objetivo de cada branch.
---

# 2. Estrutura de uma Branch

A estrutura básica de nomeação é:

```
tipo/nome-da-branch
```

Exemplo:

```
feat/analisador-lexico
```

O nome da branch deve descrever de forma simples **o que está sendo desenvolvido ou corrigido**.

---

# 3. Tipos de Branch

- **feat**

    Usado para desenvolvimento de **novas funcionalidades**.
    
    ```
    feat/parser-expressoes
    ```

---

- **fix**

    Usado para **correção de erros** no código.

    ```
    fix/erro-analise-numeros
    ```

---

- **docs**
    
    Usado para alterações na **documentação do projeto**.

    ```
    docs/manual-makefile
    ```

---

- **refactor**

    Usado quando o código é **reestruturado**, sem alterar o comportamento do sistema.

    ```
    refactor/reorganiza-parser
    ```

---

- **test**

    Usado para desenvolvimento ou atualização de **testes**.

    ```
    test/novos-arquivos-teste
    ```

---

- **chore**

    Usado para **tarefas de manutenção ou configuração do projeto**.

    ```
    chore/configuracao-makefile
    ```

# 4. Boas Práticas

* Utilizar **letras minúsculas**
* Separar palavras com **hífen (-)**
* Usar nomes **curtos e descritivos**
* Seguir sempre o padrão `tipo/nome-da-branch`

Exemplo recomendado:

```
feat/suporte-operadores-relacionais
```