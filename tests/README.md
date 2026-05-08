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

The Makefile target compiles `src/lexer/scanner.l`, runs all `scanner/inputs/*.in`, compares with `scanner/expected/*.out`, and returns non-zero exit code if any test fails.

### Files

- `scanner/inputs/*.in`: input samples consumed by the scanner
- `scanner/expected/*.out`: expected token output for each input file

### What make does

1. Compiles `src/lexer/scanner.l`.
2. Executes all `scanner/inputs/*.in` files.
3. Compares outputs with `scanner/expected/*.out`.
4. Prints PASS/FAIL and exits with non-zero status if any test fails.
