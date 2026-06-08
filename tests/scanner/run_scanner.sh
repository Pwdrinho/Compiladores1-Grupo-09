#!/bin/bash

# Para o script imediatamente se ocorrer um erro crítico
set -e

# ==========================================
# 1. Configuração de Caminhos
# ==========================================
# Descobre a pasta onde o script está rodando e a raiz do projeto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Caminhos dos arquivos baseados na sua estrutura
SCANNER_FILE="$PROJECT_ROOT/src/lexer/scanner.l"
INPUTS_DIR="$SCRIPT_DIR/inputs"
EXPECTED_DIR="$SCRIPT_DIR/expected"

# Diretórios temporários de build exclusivos para os testes
BUILD_DIR="$SCRIPT_DIR/.build"
ACTUAL_DIR="$BUILD_DIR/actual"
GENERATED_C="$BUILD_DIR/lex.yy.c"
SCANNER_EXE="$BUILD_DIR/scanner_tests.out"

# ==========================================
# 2. Verificação de Dependências
# ==========================================
for cmd in flex gcc; do
    if ! command -v $cmd &> /dev/null; then
        echo "Erro: Comando '$cmd' não encontrado. Instale-o e tente novamente."
        exit 1
    fi
done

if [ ! -f "$SCANNER_FILE" ]; then echo "Erro: Arquivo léxico não encontrado: $SCANNER_FILE"; exit 1; fi
if [ ! -d "$INPUTS_DIR" ]; then echo "Erro: Pasta de inputs não encontrada: $INPUTS_DIR"; exit 1; fi
if [ ! -d "$EXPECTED_DIR" ]; then echo "Erro: Pasta expected não encontrada: $EXPECTED_DIR"; exit 1; fi

# ==========================================
# 3. Preparação e Build do Scanner
# ==========================================
echo "Construindo o analisador léxico para testes..."
rm -rf "$BUILD_DIR"
mkdir -p "$ACTUAL_DIR"

# Define onde está a pasta da Tabela de Símbolos
TABELA_DIR="$PROJECT_ROOT/src/symbols"

# Roda o Bison primeiro para gerar o parser.tab.h e o parser.tab.c na pasta build
bison -d src/parser/parser.y -o "$BUILD_DIR/parser.tab.c"

# Roda o Flex
flex -o"$GENERATED_C" "$SCANNER_FILE"

# Compila o C gerado. Passamos -I para ele achar o parser.tab.h e o symtab.h
if ! gcc -I"$BUILD_DIR" -I"$TABELA_DIR" "$GENERATED_C" "$TABELA_DIR/symtab.c" -o "$SCANNER_EXE" 2>/dev/null; then
    gcc -I"$BUILD_DIR" -I"$TABELA_DIR" "$GENERATED_C" "$TABELA_DIR/symtab.c" -o "$SCANNER_EXE" -lfl
fi

# ==========================================
# 4. Execução e Comparação dos Testes
# ==========================================
FAILED=0
TOTAL=0

# Garante que vai ler seus arquivos .c como configuramos anteriormente
shopt -s nullglob
INPUT_FILES=("$INPUTS_DIR"/*.c)

if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo "Nenhum arquivo de teste (.c) encontrado em $INPUTS_DIR"
    exit 1
fi

echo "Iniciando os casos de teste..."
echo "----------------------------------------"

for INPUT_PATH in "${INPUT_FILES[@]}"; do
    # Pega apenas o nome do arquivo sem o caminho e sem o .c
    NAME=$(basename "$INPUT_PATH" .c)
    EXPECTED_PATH="$EXPECTED_DIR/$NAME.out"
    ACTUAL_PATH="$ACTUAL_DIR/$NAME.out"

    if [ ! -f "$EXPECTED_PATH" ]; then
        echo "Erro: Arquivo de gabarito não encontrado: $EXPECTED_PATH"
        exit 1
    fi

    # Joga o arquivo de teste para dentro do scanner e salva em actual
    "$SCANNER_EXE" < "$INPUT_PATH" > "$ACTUAL_PATH" || true

    # Faz o diff silencioso ignorando quebras de linha Windows/Linux
    if diff -u --strip-trailing-cr "$EXPECTED_PATH" "$ACTUAL_PATH" > /dev/null 2>&1; then
        echo -e "\e[32mPASS $NAME\e[0m" # Verde
    else
        echo -e "\e[31mFAIL $NAME\e[0m" # Vermelho
        echo "  Esperado : $EXPECTED_PATH"
        echo "  Obtido   : $ACTUAL_PATH"
        echo "  Diferenças:"
        diff -u --strip-trailing-cr "$EXPECTED_PATH" "$ACTUAL_PATH"
        FAILED=$((FAILED + 1))
    fi
    TOTAL=$((TOTAL + 1))
done

# ==========================================
# 5. Resultado Final
# ==========================================
PASSED=$((TOTAL - FAILED))
echo "----------------------------------------"
echo "Resultado: $PASSED/$TOTAL testes passaram."

if [ "$FAILED" -gt 0 ]; then
    exit 1
fi
exit 0