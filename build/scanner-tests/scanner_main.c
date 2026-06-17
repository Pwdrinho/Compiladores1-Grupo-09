#include "parser.tab.h"
int yylex(void);
YYSTYPE yylval;
int main(void) {
    while (yylex() != 0) {}
    return 0;
}
