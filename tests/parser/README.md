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