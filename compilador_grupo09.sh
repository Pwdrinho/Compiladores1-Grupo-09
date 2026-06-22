#!/bin/bash

# Verifica se um arquivo foi passado como argumento
if [ -z "$1" ]; then
    echo "Uso: ./compilador_grupo09.sh <arquivo_de_teste.c>"
    exit 1
fi

ARQUIVO_ENTRADA=$1
# Extrai o nome base (ex: teste.c -> teste)
NOME_BASE=$(basename "$ARQUIVO_ENTRADA" .c)
ARQUIVO_GO="saida.go"

echo "--- Iniciando processo de build ---"

# 1. Gerar parser e lexer
bison -d src/parser/parser.y
flex src/lexer/scanner.l

# 2. Compilar o compilador
gcc lex.yy.c parser.tab.c src/ast/ast.c src/symbols/symtab.c src/semantico/semantico.c src/intermediario/intermediario.c src/gerador/gerador.c -I src/ast -I src/symbols -I src/semantico -I src/intermediario -I src/gerador -o compilador_grupo09
if [ $? -ne 0 ]; then
    echo "Erro na compilação do compilador!"
    exit 1
fi

echo "--- Compilador gerado com sucesso ---"

# 3. Executar o compilador no arquivo de teste
./compilador_grupo09 < "$ARQUIVO_ENTRADA"

echo "Código Go gerado em: $ARQUIVO_GO"
