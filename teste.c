// 1. Variáveis Globais (com e sem atribuição)
int variavel_global = 100;
int vetor_global[10];

// 2. Função com parâmetros e retorno de valor (Matemática pesada)
int operacoes_matematicas(int a, int b) {
    int soma = a + b;
    int sub = a - b;
    int mult = a * b;
    int div = a / b;
    int mod = a % b;
    int resultado;
    
    // Expressão longa para testar a precedência e múltiplos nós binários
    resultado = soma + sub * mult / div % mod;
    
    return resultado;
}

// 3. Função void, laços, vetores e condicionais
void lacos_e_condicionais(int limite) {
    int i;
    int j = 0;
    int valor_vetor;
    
    // For com atribuição simples e +=
    for (i = 0; i < limite; i += 1) {
        j++; // Incremento pós
    }
    
    // For com atribuição -= e pré-decremento
    for (i -= 2; i >= 0; --i) {
        --j; // Decremento pré
    }

    // While simples com decremento pós
    while (j > 0) {
        j--; 
    }
    
    // Leitura de vetor (a gramática permite ler, mas não permite vetor[x] = y)
    valor_vetor = vetor_global[2];
    
    // If e Else com parênteses, AND, OR e operadores relacionais diversos
    if ((valor_vetor == 0) && (j != 1) || (i <= 5)) {
        ++valor_vetor;
    } else {
        valor_vetor--;
    }
    
    // Retorno vazio
    return;
}

// 4. Ponto de entrada
int main() {
    int x = 10;
    int y = 3;
    int c;
    
    // Chamada de função com argumentos
    c = operacoes_matematicas(x, y);
    
    if (c > 0) {
        lacos_e_condicionais(5);
    }
    
    return c;
}