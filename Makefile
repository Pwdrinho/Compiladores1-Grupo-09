CC      ?= gcc
FLEX    ?= flex
BISON   ?= bison
LDLIBS  ?= -lfl
CFLAGS  ?= -Wall -Wextra -g

# Flags opcionais de cobertura. O build normal fica limpo; make coverage ativa essas flags.
COV_FLAGS ?=
COVERAGE_FLAGS := -fprofile-arcs -ftest-coverage

SCANNER ?= src/lexer/scanner.l
PARSER  ?= src/parser/parser.y

AST_H   := src/ast/ast.h
AST_C   := src/ast/ast.c

# Se existir symtab.c, ele será compilado junto.
# Se não existir, o Makefile continua funcionando.
SYMTAB_C := $(wildcard src/symbols/symtab.c)
SEMANTICO_C := src/semantico/semantico.c
INTERMEDIARIO_C := src/intermediario/intermediario.c
GERADOR_C := src/gerador/gerador.c
COMPILER_SRCS := $(AST_C) $(SYMTAB_C) $(SEMANTICO_C) $(INTERMEDIARIO_C) $(GERADOR_C)

BUILD   ?= build

PARSER_C := $(BUILD)/parser.tab.c
PARSER_H := $(BUILD)/parser.tab.h
LEX_C    := $(BUILD)/lex.yy.c

COMPILER := $(BUILD)/compilador
TARGET   := $(COMPILER)

INCLUDES := -I$(BUILD) -Isrc/ast -Isrc/symbols -Isrc/semantico -Isrc/intermediario -Isrc/gerador

SCANNER_TEST_BUILD    := $(BUILD)/scanner-tests
SCANNER_TEST_GEN_C    := $(SCANNER_TEST_BUILD)/lex.yy.c
SCANNER_TEST_STUB     := $(SCANNER_TEST_BUILD)/scanner_main.c
SCANNER_TEST_TARGET   := $(SCANNER_TEST_BUILD)/scanner_tests
SCANNER_TEST_INPUTS   := tests/scanner/inputs
SCANNER_TEST_EXPECTED := tests/scanner/expected
SCANNER_TEST_ACTUAL   := $(SCANNER_TEST_BUILD)/actual
COV_REPORT_DIR        := $(BUILD)/coverage-html

PARSER_TEST_BUILD    := $(BUILD)/parser-tests
PARSER_TEST_INPUTS   := tests/parser/inputs
PARSER_TEST_EXPECTED := tests/parser/expected
PARSER_TEST_ACTUAL   := $(PARSER_TEST_BUILD)/actual

CODEGEN_TEST_BUILD    := $(BUILD)/codegen-tests
CODEGEN_TEST_INPUTS   := tests/codegen/inputs
CODEGEN_TEST_EXPECTED := tests/codegen/expected
CODEGEN_TEST_ACTUAL   := $(CODEGEN_TEST_BUILD)/actual

VERBOSE ?= 0

TEST_01 := 01_keywords.c
TEST_02 := 02_identifiers_numbers.c
TEST_03 := 03_double_operators.c
TEST_04 := 04_single_operators_delimiters.c
TEST_05 := 05_comments_whitespace.c
TEST_06 := 06_unknown_chars.c
TEST_07 := 07_mixed_snippet.c
TEST_08 := 08_simple_program.c
TEST_09 := 09_function_and_condition.c
TEST_10 := 10_pointers_arrays.c
TEST_11 := 11_trailing_dot_literal.c
TEST_12 := 12_unclosed_block_comment.c

PARSER_TEST_01 := 01_simple_function.c
PARSER_TEST_02 := 02_function_with_params_and_if.c
PARSER_TEST_03 := 03_local_decl_increment_return.c
PARSER_TEST_04 := 04_vector_access.c
PARSER_TEST_05 := 05_for_loop.c
PARSER_TEST_06 := 06_if_else.c
PARSER_TEST_07 := 07_multiple_functions.c
PARSER_TEST_08 := 08_while_prefix_return_void.c
PARSER_TEST_09 := 09_function_call.c
PARSER_TEST_10 := 10_undeclared_function.c
PARSER_TEST_11 := 11_wrong_argument_count.c
PARSER_TEST_12 := 12_void_return_value.c
PARSER_TEST_13 := 13_missing_return_value.c
PARSER_TEST_14 := 14_duplicate_function.c

.PHONY: all run clean help test scanner-test parser-test codegen-test scanner_test test-scanner scanner-unit-test parser-unit-test parser_test test-parser check-parser check-scanner check-ast coverage

all: $(COMPILER)

test: scanner-test parser-test codegen-test

scanner_test: scanner-test

test-scanner: scanner-test

help:
	@echo "Targets available:"
	@echo "  make all                         - build the compiler in build/"
	@echo "  make run                         - run the compiler"
	@echo "  make scanner-test                - run scanner tests with DEBUG_LEXER=1"
	@echo "  make parser-test                 - run parser tests"
	@echo "  make codegen-test                - run C to Go generation tests"
	@echo "  make scanner-test VERBOSE=1      - print expected/actual .out content"
	@echo "  make scanner-unit-test TEST=n    - run one scanner test by number"
	@echo "  make scanner-unit-test TEST=name - run one scanner test by base name"
	@echo "  make parser-unit-test TEST=n     - run one parser test by number"
	@echo "  make parser-unit-test TEST=name  - run one parser test by base name"
	@echo "  make coverage                    - run tests and generate an HTML coverage report using LCOV"
	@echo "  make clean                       - remove build artifacts"

check-parser:
	@if [ ! -f "$(PARSER)" ]; then \
		echo "Erro: arquivo $(PARSER) nao encontrado."; \
		exit 1; \
	fi

check-scanner:
	@if [ ! -f "$(SCANNER)" ]; then \
		echo "Erro: arquivo $(SCANNER) nao encontrado."; \
		exit 1; \
	fi

check-ast:
	@if [ ! -f "$(AST_H)" ]; then \
		echo "Erro: arquivo $(AST_H) nao encontrado."; \
		exit 1; \
	fi
	@if [ ! -f "$(AST_C)" ]; then \
		echo "Erro: arquivo $(AST_C) nao encontrado."; \
		exit 1; \
	fi

$(BUILD):
	mkdir -p $(BUILD)

$(SCANNER_TEST_BUILD):
	mkdir -p $(SCANNER_TEST_BUILD)

$(PARSER_C) $(PARSER_H): $(PARSER) $(AST_H) | check-parser check-ast $(BUILD)
	$(BISON) -d -o $(PARSER_C) $(PARSER)

$(LEX_C): $(SCANNER) $(PARSER_H) | check-scanner $(BUILD)
	$(FLEX) -o $(LEX_C) $(SCANNER)

$(COMPILER): $(PARSER_C) $(LEX_C) $(COMPILER_SRCS) Makefile
	$(CC) $(CFLAGS) $(COV_FLAGS) $(INCLUDES) $(PARSER_C) $(LEX_C) $(COMPILER_SRCS) -o $(COMPILER) $(LDLIBS) $(COV_FLAGS)

run: $(COMPILER)
	./$(COMPILER)

# --------------------------------------------------------------------
# Testes do scanner
# --------------------------------------------------------------------

$(SCANNER_TEST_GEN_C): $(SCANNER) $(PARSER_C) $(PARSER_H) | check-scanner $(SCANNER_TEST_BUILD)
	$(FLEX) -o $(SCANNER_TEST_GEN_C) $(SCANNER)

$(SCANNER_TEST_STUB): | $(SCANNER_TEST_BUILD)
	@printf '#include "parser.tab.h"\n' > $(SCANNER_TEST_STUB)
	@printf 'int yylex(void);\n' >> $(SCANNER_TEST_STUB)
	@printf 'YYSTYPE yylval;\n' >> $(SCANNER_TEST_STUB)
	@printf 'int main(void) {\n' >> $(SCANNER_TEST_STUB)
	@printf '    while (yylex() != 0) {}\n' >> $(SCANNER_TEST_STUB)
	@printf '    return 0;\n' >> $(SCANNER_TEST_STUB)
	@printf '}\n' >> $(SCANNER_TEST_STUB)

$(SCANNER_TEST_TARGET): $(SCANNER_TEST_GEN_C) $(SCANNER_TEST_STUB) Makefile
	$(CC) $(CFLAGS) $(COV_FLAGS) -DDEBUG_LEXER=1 $(INCLUDES) $(SCANNER_TEST_GEN_C) $(SCANNER_TEST_STUB) -o $(SCANNER_TEST_TARGET) $(LDLIBS) $(COV_FLAGS)

scanner-test: $(SCANNER_TEST_TARGET)
	@mkdir -p $(SCANNER_TEST_ACTUAL)
	@set -e; failed=0; total=0; \
	for input in $(SCANNER_TEST_INPUTS)/*.c; do \
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
		echo "Nenhum arquivo .c encontrado em $(SCANNER_TEST_INPUTS)"; \
		exit 1; \
	fi; \
	echo "Result: $$((total - failed))/$$total tests passed."; \
	if [ "$$failed" -ne 0 ]; then \
		exit 1; \
	fi

parser-test: $(COMPILER)
	@mkdir -p $(PARSER_TEST_ACTUAL)
	@set -e; \
	failed=0; \
	total=0; \
	for input in $(PARSER_TEST_INPUTS)/*.c; do \
		if [ ! -f "$$input" ]; then \
			continue; \
		fi; \
		name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
		expected="$(PARSER_TEST_EXPECTED)/$$name.out"; \
		actual="$(PARSER_TEST_ACTUAL)/$$name.out"; \
		total=$$((total + 1)); \
		if [ ! -f "$$expected" ]; then \
			echo "FAIL $$name (arquivo esperado ausente: $$expected)"; \
			failed=$$((failed + 1)); \
			continue; \
		fi; \
		"$(COMPILER)" < "$$input" > "$$actual" 2>&1 || true; \
		sed -E -i 's/0x[0-9a-fA-F]+/0xADDR/g' "$$actual"; \
		if diff -u --strip-trailing-cr "$$expected" "$$actual" > /dev/null; then \
			echo "PASS $$name"; \
		else \
			echo "FAIL $$name"; \
			diff -u --strip-trailing-cr "$$expected" "$$actual" || true; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	echo "Parser Result: $$((total - failed))/$$total tests passed."; \
	if [ "$$failed" -ne 0 ]; then \
		exit 1; \
	fi

codegen-test: $(COMPILER)
	@mkdir -p $(CODEGEN_TEST_ACTUAL)
	@set -e; \
	failed=0; \
	total=0; \
	for input in $(CODEGEN_TEST_INPUTS)/*.c; do \
		if [ ! -f "$$input" ]; then \
			continue; \
		fi; \
		name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
		expected="$(CODEGEN_TEST_EXPECTED)/$$name.go"; \
		actual="$(CODEGEN_TEST_ACTUAL)/$$name.go"; \
		compiler_out="$(CODEGEN_TEST_ACTUAL)/$$name.compiler.out"; \
		total=$$((total + 1)); \
		if [ ! -f "$$expected" ]; then \
			echo "FAIL $$name (arquivo esperado ausente: $$expected)"; \
			failed=$$((failed + 1)); \
			continue; \
		fi; \
		if ! "$(COMPILER)" < "$$input" > "$$compiler_out" 2>&1; then \
			echo "FAIL $$name (compilador retornou erro)"; \
			cat "$$compiler_out"; \
			failed=$$((failed + 1)); \
			continue; \
		fi; \
		if [ ! -f saida.go ]; then \
			echo "FAIL $$name (saida.go nao foi gerado)"; \
			failed=$$((failed + 1)); \
			continue; \
		fi; \
		cp saida.go "$$actual"; \
		if diff -u --strip-trailing-cr "$$expected" "$$actual" > /dev/null; then \
			echo "PASS $$name"; \
		else \
			echo "FAIL $$name"; \
			diff -u --strip-trailing-cr "$$expected" "$$actual" || true; \
			failed=$$((failed + 1)); \
		fi; \
	done; \
	if [ "$$total" -eq 0 ]; then \
		echo "Nenhum arquivo .c encontrado em $(CODEGEN_TEST_INPUTS)"; \
		exit 1; \
	fi; \
	echo "Codegen Result: $$((total - failed))/$$total tests passed."; \
	if [ "$$failed" -ne 0 ]; then \
		exit 1; \
	fi

scanner-unit-test: $(SCANNER_TEST_TARGET)
	@set -e; \
	if [ -n "$(INPUT)" ]; then \
		input="$(INPUT)"; \
	elif [ -n "$(TEST)" ]; then \
		mapped="$(strip $(TEST_$(TEST)))"; \
		if [ -z "$$mapped" ]; then \
			mapped="$(strip $(TEST_0$(TEST)))"; \
		fi; \
		if [ -n "$$mapped" ]; then \
			input="$(SCANNER_TEST_INPUTS)/$$mapped"; \
		else \
			case "$(TEST)" in \
				''|*[!0-9]*) input="$(SCANNER_TEST_INPUTS)/$(TEST)"; \
					if [ "$${input##*.}" = "$$input" ]; then input="$$input.c"; fi ;; \
				*) input="$(SCANNER_TEST_INPUTS)/$$(printf '%02d' "$(TEST)").c" ;; \
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

parser-unit-test: $(COMPILER)
	@set -e; \
	if [ -n "$(INPUT)" ]; then \
		input="$(INPUT)"; \
	elif [ -n "$(TEST)" ]; then \
		mapped="$(strip $(PARSER_TEST_$(TEST)))"; \
		if [ -z "$$mapped" ]; then \
			mapped="$(strip $(PARSER_TEST_0$(TEST)))"; \
		fi; \
		if [ -n "$$mapped" ]; then \
			input="$(PARSER_TEST_INPUTS)/$$mapped"; \
		else \
			case "$(TEST)" in \
				''|*[!0-9]*) input="$(PARSER_TEST_INPUTS)/$(TEST)"; \
					if [ "$${input##*.}" = "$$input" ]; then input="$$input.c"; fi ;; \
				*) input="$(PARSER_TEST_INPUTS)/$$(printf '%02d' "$(TEST)").c" ;; \
			esac; \
		fi; \
	else \
		echo "Use TEST=<nome> ou INPUT=<caminho>"; \
		exit 1; \
	fi; \
	name=$$(basename "$$input" | sed 's/\.[^.]*$$//'); \
	expected="$(PARSER_TEST_EXPECTED)/$$name.out"; \
	actual="$(PARSER_TEST_ACTUAL)/$$name.out"; \
	mkdir -p $(PARSER_TEST_ACTUAL); \
	if [ ! -f "$$input" ]; then \
		echo "Arquivo de entrada nao encontrado: $$input"; \
		exit 1; \
	fi; \
	if [ ! -f "$$expected" ]; then \
		echo "Arquivo esperado nao encontrado: $$expected"; \
		exit 1; \
	fi; \
	"$(COMPILER)" < "$$input" > "$$actual" 2>&1 || true; \
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

parser_test: parser-unit-test

test-parser: parser-unit-test

coverage:
	$(MAKE) clean
	$(MAKE) test COV_FLAGS="$(COVERAGE_FLAGS)"
	@echo "Coletando dados de cobertura de todas as etapas (Scanner + Parser)..."
	lcov --capture --directory $(SCANNER_TEST_BUILD) --output-file $(BUILD)/scanner_coverage.info
	lcov --capture --directory $(BUILD) --output-file $(BUILD)/parser_coverage.info
	
	@echo "Mesclando os relatórios de cobertura..."
	lcov --add-tracefile $(BUILD)/scanner_coverage.info --add-tracefile $(BUILD)/parser_coverage.info --output-file $(BUILD)/total_coverage.info
	
	@echo "Limpando arquivos gerados e dependências externas..."
	lcov --remove $(BUILD)/total_coverage.info '/usr/*' '$(SCANNER_TEST_BUILD)/*' '$(BUILD)/parser.tab.c' '$(BUILD)/lex.yy.c' --output-file $(BUILD)/coverage_clean.info --ignore-errors unused
	
	@echo "Gerando páginas visuais em HTML para o projeto..."
	genhtml $(BUILD)/coverage_clean.info --output-directory $(COV_REPORT_DIR) --ignore-errors source,unsupported
	@echo "========================================================================="
	@echo "Relatório GLOBAL de cobertura gerado com sucesso em: $(COV_REPORT_DIR)/index.html"
	@echo "========================================================================="

clean:
	rm -rf $(BUILD)
