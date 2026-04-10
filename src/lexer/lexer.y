%{
#include <stdio.h>
%}

%%

int        { printf("TIPO_INT\n"); }
float      { printf("TIPO_FLOAT\n"); }
char       { printf("TIPO_CHAR\n"); }
double     { printf("TIPO_DOUBLE\n"); }
short      { printf("TIPO_SHORT\n"); }
long       { printf("TIPO_LONG\n"); }
signed     { printf("TIPO_SIGNED\n"); }
unsigned   { printf("TIPO_UNSIGNED\n"); }
void       { printf("TIPO_VOID\n"); }

[ \t\n]+   ;

.          { printf("OUTRO\n"); }

%%

int main() {
    yylex();
    return 0;
}