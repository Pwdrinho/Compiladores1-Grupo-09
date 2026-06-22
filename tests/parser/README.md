## Parser tests

Automated tests for `src/parser/parser.y`.

### Run

From the project root:

```bash
make parser-test
```

or:

```bash
make test
```

### Layout

- `inputs/*.c`: programs used as parser input
- `expected/*.out`: expected parser output, including the AST printed by the compiler

### Scope

These tests focus on parser acceptance and AST shape. The symbol table is still compiled with the project, but it is not deeply exercised by the grammar yet.

Current suite highlights:
- Coverage for `while`, simple declaration, prefix `++`/`--`, and `return;` in `08_while_prefix_return_void.c`.
- `09_function_call.c` documents the supported syntax for simple function call statements.
- `10_undeclared_function.c` to `14_duplicate_function.c` document semantic errors for function signatures, arguments and returns.
