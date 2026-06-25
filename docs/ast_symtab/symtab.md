## 1. Visão Geral
A Tabela de Símbolos é por gerenciar os identificadores (variáveis e funções). Ela utiliza uma **Tabela Hash com tratamento de colisões via lista encadeada** para garantir a organização.

## 2. Estrutura de Dados
O sistema armazena cada identificador em uma estrutura Simbolo:

* **`nome`**: Nome original da variável no código-fonte.
* **`nome_intermediario`**: Nome único gerado (ex: `variavel_0`), garantindo que não haja colisões de escopo durante a tradução para Go. (Deixamos de implementar atualmente)
* **`tipo_dado`**: Enum que armazena se o símbolo é `INT`, `FLOAT` ou `VOID`.
* **`escopo`**: Nível de profundidade atual (ex: 0 para global, >0 para locais).
* **`ativo`**: Booleano que controla a visibilidade (1 = visível, 0 = inativo após sair do escopo).
* **`proximo`**: Ponteiro para o próximo símbolo na mesma posição da tabela hash.

## 3. Funcionalidades Principais

### Gerenciamento de Escopo
O compilador suporta escopos aninhados através de um contador global escopo_atual:

* **`entrar_escopo`**: Incrementa o nível de profundidade.
* **`sair_escopo`**: Inativa todas as variáveis associadas ao escopo atual (via `remover_escopo`) e retorna ao nível anterior.

### Busca e Inserção

* **`calcular_hash`**: Implementa a hash utilizando a constante 33, a tabela de símbolos tem o tamanho 211.
* **`buscar_simbolo`**: Retorna a ocorrência mais recente (ativa) de uma variável, permitindo que o compilador encontre facilmente a variável correta em meio a múltiplos escopos.
* **`buscar_simbolo_escopo`**: Realiza uma verificação para identificar variáveis no mesmo nível de escopo.