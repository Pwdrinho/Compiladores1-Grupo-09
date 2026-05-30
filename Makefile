CC      ?= gcc
FLEX    ?= flex
BISON   ?= bison
LDLIBS  ?= -lfl


SCANNER ?= src/scanner.l
PARSER  ?= src/parser.y


BUILD   ?= build
GEN_C   := $(BUILD)/lex.yy.c
PARSER_C := $(BUILD)/parser.tab.c
PARSER_H := $(BUILD)/parser.tab.h
TARGET  := $(BUILD)/lexer.exe
COMPILER_TARGET := $(BUILD)/compilador.exe


SCANNER_TEST_BUILD    := $(BUILD)/scanner-tests
SCANNER_TEST_GEN_C    := $(SCANNER_TEST_BUILD)/lex.yy.c
SCANNER_TEST_TARGET   := $(SCANNER_TEST_BUILD)/scanner_tests
SCANNER_TEST_INPUTS   := tests/scanner/inputs
SCANNER_TEST_EXPECTED := tests/scanner/expected
SCANNER_TEST_ACTUAL   := $(SCANNER_TEST_BUILD)/actual


PARSER_TEST_BUILD    := $(BUILD)/parser-tests
PARSER_TEST_INPUTS   := tests/parser/inputs
PARSER_TEST_EXPECTED := tests/parser/expected
PARSER_TEST_ACTUAL   := $(PARSER_TEST_BUILD)/actual

VERBOSE ?= 0

.PHONY: all run clean check check-scanner check-parser scanner-test parser-test test help

all: $(COMPILER_TARGET)

test: scanner-test parser-test

help:
	@echo "Targets available:";
	@echo "  make all            - compila o flex e o bison juntos em build/";
	@echo "  make scanner-test   - roda apenas os testes lexicos";
	@echo "  make parser-test    - roda apenas os testes sintaticos";
	@echo "  make test           - roda todos os testes (lexico e sintatico)";
	@echo "  make clean          - remove arquivos da pasta build";


check-scanner:
	@if [ ! -f "$(SCANNER)" ]; then \
		echo "Erro: arquivo $(SCANNER) nao encontrado."; exit 1; \
	fi

check-parser:
	@if [ ! -f "$(PARSER)" ]; then \
		echo "Erro: arquivo $(PARSER) nao encontrado."; exit 1; \
	fi

$(BUILD):
	mkdir -p $(BUILD)


$(PARSER_C) $(PARSER_H): $(PARSER) | check-parser $(BUILD)
	$(BISON) -d -o $(PARSER_C) $<

$(GEN_C): $(SCANNER) $(PARSER_H) | check-scanner $(BUILD)
	$(FLEX) -o $@ $<

$(COMPILER_TARGET): $(PARSER_C) $(GEN_C)
	$(CC) $(PARSER_C) $(GEN_C) -o $@ $(LDLIBS)


$(SCANNER_TEST_BUILD):
	mkdir -p $(SCANNER_TEST_BUILD)

$(SCANNER_TEST_GEN_C): $(SCANNER) | check-scanner $(SCANNER_TEST_BUILD)
	$(FLEX) -o $@ $<

$(SCANNER_TEST_TARGET): $(SCANNER_TEST_GEN_C)
	$(CC) $< -o $@ $(LDLIBS)

scanner-test: $(SCANNER_TEST_TARGET)
	@mkdir -p $(SCANNER_TEST_ACTUAL)
	@echo "--- Rodando Testes Léxicos ---"
	@set -e; failed=0; total=0; \
	for input in $(SCANNER_TEST_INPUTS)/*.in $(SCANNER_TEST_INPUTS)/*.c; do \
		if [ ! -f "$$input" ]; then continue; fi; \
		name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
		expected="$(SCANNER_TEST_EXPECTED)/$$name.out"; \
		actual="$(SCANNER_TEST_ACTUAL)/$$name.out"; \
		total=$$((total + 1)); \
		if [ ! -f "$$expected" ]; then echo "FAIL $$name (esperado ausente)"; failed=$$((failed + 1)); continue; fi; \
		"$(SCANNER_TEST_TARGET)" < "$$input" > "$$actual" || true; \
		if diff -u --strip-trailing-cr "$$expected" "$$actual" > /dev/null; then \
			echo "PASS $$name"; \
		else \
			echo "FAIL $$name"; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo "Lexer Result: $$((total - failed))/$$total passed."; \
	if [ "$$failed" -ne 0 ]; then exit 1; fi


$(PARSER_TEST_BUILD):
	mkdir -p $(PARSER_TEST_BUILD)

parser-test: $(COMPILER_TARGET)
	@mkdir -p $(PARSER_TEST_ACTUAL)
	@echo "--- Rodando Testes Sintáticos ---"
	@set -e; failed=0; total=0; \
	for input in $(PARSER_TEST_INPUTS)/*.c; do \
		if [ ! -f "$$input" ]; then continue; fi; \
		name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
		expected="$(PARSER_TEST_EXPECTED)/$$name.out"; \
		actual="$(PARSER_TEST_ACTUAL)/$$name.out"; \
		total=$$((total + 1)); \
		if [ ! -f "$$expected" ]; then echo "FAIL $$name (esperado ausente)"; failed=$$((failed + 1)); continue; fi; \
		"$(COMPILER_TARGET)" < "$$input" > "$$actual" 2>&1 || true; \
		if diff -u --strip-trailing-cr "$$expected" "$$actual" > /dev/null; then \
			echo "PASS $$name"; \
		else \
			echo "FAIL $$name"; \
			diff -u --strip-trailing-cr "$$expected" "$$actual" || true; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo "Parser Result: $$((total - failed))/$$total passed."; \
	if [ "$$failed" -ne 0 ]; then exit 1; fi

clean:
	rm -rf $(BUILD)