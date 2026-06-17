## Scanner tests

This folder contains automated tests for `src/lexer/scanner.l`.

### Preferred run (Makefile)

From project root:

```bash
make scanner-test
```

or:

```bash
make test
```

The Makefile target compiles `src/lexer/scanner.l`, runs all `scanner/inputs/*.c`, compares with `scanner/expected/*.out`, and returns non-zero exit code if any test fails.

### Files

- `scanner/inputs/*.c`: input samples consumed by the scanner
- `scanner/expected/*.out`: expected token output for each input file

### What make does

1. Compiles `src/lexer/scanner.l`.
2. Executes all `scanner/inputs/*.c` files.
3. Compares outputs with `scanner/expected/*.out`.
4. Prints PASS/FAIL and exits with non-zero status if any test fails.

## Parser tests

This folder also contains automated tests for `src/parser/parser.y`.

### Preferred run (Makefile)

From project root:

```bash
make parser-test
```

or:

```bash
make test
```

The Makefile target compiles the compiler, runs all `parser/inputs/*.c`, compares with `parser/expected/*.out`, and returns non-zero exit code if any test fails.

### Files

- `parser/inputs/*.c`: parser input samples
- `parser/expected/*.out`: expected AST output for each input file

### What make does

1. Builds the compiler.
2. Executes all `parser/inputs/*.c` files.
3. Compares outputs with `parser/expected/*.out`.
4. Prints PASS/FAIL and exits with non-zero status if any test fails.

### Notable scanner behavior locked by tests

- `11_trailing_dot_literal.c`: `10.` is tokenized as `NUMBER(10)` followed by `TK_OP_PONTO`.
- `12_unclosed_block_comment.c`: unclosed block comment is not consumed as a comment token; characters are tokenized according to existing rules.

### Notable parser coverage

- `08_while_prefix_return_void.c`: covers `while`, simple declaration, prefix `++`/`--` and `return;`.
- `09_function_call_not_supported.c`: negative test documenting that function call statements are not yet supported by the grammar.