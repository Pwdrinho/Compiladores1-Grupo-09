CC      ?= gcc
FLEX    ?= flex
LDLIBS  ?= -lfl

SCANNER ?= src/lexer/scanner.l
BUILD   ?= build
GEN_C   := $(BUILD)/lex.yy.c
TARGET  := $(BUILD)/lexer.exe

SCANNER_TEST_BUILD    := $(BUILD)/scanner-tests
SCANNER_TEST_GEN_C    := $(SCANNER_TEST_BUILD)/lex.yy.c
SCANNER_TEST_TARGET   := $(SCANNER_TEST_BUILD)/scanner_tests
SCANNER_TEST_INPUTS   := tests/scanner/inputs
SCANNER_TEST_EXPECTED := tests/scanner/expected
SCANNER_TEST_ACTUAL   := $(SCANNER_TEST_BUILD)/actual
VERBOSE ?= 0

TEST_01 := 01_keywords.in
TEST_02 := 02_identifiers_numbers.in
TEST_03 := 03_double_operators.in
TEST_04 := 04_single_operators_delimiters.in
TEST_05 := 05_comments_whitespace.in
TEST_06 := 06_unknown_chars.in
TEST_07 := 07_mixed_snippet.in
TEST_08 := 08_simple_program.c
TEST_09 := 09_function_and_condition.c
TEST_10 := 10_pointers_arrays.c

.PHONY: all run clean check check-scanner scanner-test test scanner_test test-scanner scanner-test-one help

all: $(TARGET)

test: scanner-test

scanner_test: scanner-test

test-scanner: scanner-test

help:
	@echo "Targets available:";
	@echo "  make all            - build the lexer in build/";
	@echo "  make run            - run the main lexer binary";
	@echo "  make scanner-test   - run the scanner test suite";
	@echo "  make scanner-test VERBOSE=1 - print expected/actual .out content";
	@echo "  make scanner-unit-test TEST=n - run the test mapped by TEST_n";
	@echo "  make scanner-unit-test TEST=name - run one test by base name";
	@echo "  make scanner-unit-test INPUT=tests/scanner/inputs/name - run one test by path";
	@echo "  make test           - alias for scanner-test";
	@echo "  make clean          - remove build artifacts";

check-scanner:
	@if [ ! -f "$(SCANNER)" ]; then \
		echo "Erro: arquivo $(SCANNER) nao encontrado."; \
		echo "Ajuste a variavel SCANNER no Makefile para apontar para o scanner correto."; \
		exit 1; \
	fi

$(BUILD):
	mkdir -p $(BUILD)

$(GEN_C): $(SCANNER) | check $(BUILD)
	$(FLEX) -o $@ $<

$(TARGET): $(GEN_C)
	$(CC) $< -o $@ $(LDLIBS)

$(SCANNER_TEST_BUILD):
	mkdir -p $(SCANNER_TEST_BUILD)

$(SCANNER_TEST_GEN_C): $(SCANNER) | check-scanner $(SCANNER_TEST_BUILD)
	$(FLEX) -o $@ $<

$(SCANNER_TEST_TARGET): $(SCANNER_TEST_GEN_C)
	$(CC) $< -o $@ $(LDLIBS)

scanner-test: $(SCANNER_TEST_TARGET)
	@mkdir -p $(SCANNER_TEST_ACTUAL)
	@set -e; \
	failed=0; \
	total=0; \
	for input in $(SCANNER_TEST_INPUTS)/*.in $(SCANNER_TEST_INPUTS)/*.c; do \
		if [ ! -f "$$input" ]; then \
			continue; \
		fi; \
		name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
		expected="$(SCANNER_TEST_EXPECTED)/$$name.out"; \
		actual="$(SCANNER_TEST_ACTUAL)/$$name.out"; \
		total=$$((total + 1)); \
		if [ ! -f "$$expected" ]; then \
			echo "FAIL $$name (arquivo esperado ausente: $$expected)"; \
			failed=$$((failed + 1)); \
			continue; \
		fi; \
		"$(SCANNER_TEST_TARGET)" < "$$input" > "$$actual"; \
		if diff -u --strip-trailing-cr "$$expected" "$$actual" > /dev/null; then \
			echo "PASS $$name"; \
			if [ "$(VERBOSE)" -ne 0 ]; then \
				echo "--- expected: $$expected ---"; \
				cat "$$expected"; \
				echo "--- actual: $$actual ---"; \
				cat "$$actual"; \
			fi; \
		else \
			echo "FAIL $$name"; \
			echo "--- expected: $$expected ---"; \
			cat "$$expected"; \
			echo "--- actual: $$actual ---"; \
			cat "$$actual"; \
			diff -u --strip-trailing-cr "$$expected" "$$actual" || true; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	if [ "$$total" -eq 0 ]; then \
		echo "Nenhum arquivo .in encontrado em $(SCANNER_TEST_INPUTS)"; \
		exit 1; \
	fi; \
	echo "Result: $$((total - failed))/$$total tests passed."; \
	if [ "$$failed" -ne 0 ]; then \
		exit 1; \
	fi

scanner-unit-test: $(SCANNER_TEST_TARGET)
	@set -e; \
	if [ -n "$(INPUT)" ]; then \
		input="$(INPUT)"; \
	elif [ -n "$(TEST)" ]; then \
		mapped="$(strip $(TEST_$(TEST)))"; \
		if [ -n "$$mapped" ]; then \
			input="$(SCANNER_TEST_INPUTS)/$$mapped"; \
		else \
			input="$(SCANNER_TEST_INPUTS)/$(TEST)"; \
			case "$$input" in \
				*.in|*.c) ;; \
				*) if [ -f "$$input.in" ]; then \
					input="$$input.in"; \
				elif [ -f "$$input.c" ]; then \
					input="$$input.c"; \
				else \
					input="$$input.in"; \
				fi ;; \
			esac; \
		fi; \
	else \
		echo "Use TEST=<nome> ou INPUT=<caminho>"; \
		exit 1; \
	fi; \
	name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
	expected="$(SCANNER_TEST_EXPECTED)/$$name.out"; \
	actual="$(SCANNER_TEST_ACTUAL)/$$name.out"; \
	mkdir -p $(SCANNER_TEST_ACTUAL); \
	if [ ! -f "$$input" ]; then \
		echo "Arquivo de entrada nao encontrado: $$input"; \
		exit 1; \
	fi; \
	if [ ! -f "$$expected" ]; then \
		echo "Arquivo esperado nao encontrado: $$expected"; \
		exit 1; \
	fi; \
	"$(SCANNER_TEST_TARGET)" < "$$input" > "$$actual"; \
	if diff -u --strip-trailing-cr "$$expected" "$$actual" > /dev/null; then \
		echo "PASS $$name"; \
		echo "--- expected: $$expected ---"; \
		cat "$$expected"; \
		echo "--- actual: $$actual ---"; \
		cat "$$actual"; \
	else \
		echo "FAIL $$name"; \
		echo "--- expected: $$expected ---"; \
		cat "$$expected"; \
		echo "--- actual: $$actual ---"; \
		cat "$$actual"; \
		diff -u --strip-trailing-cr "$$expected" "$$actual" || true; \
		exit 1; \
	fi

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD)