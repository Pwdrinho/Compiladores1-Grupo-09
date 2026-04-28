%{
#include <stdio.h>
#include "parser.tab.h"
%}
/* Definições de padrões de token e ações */
%%

auto        { printf("KW_AUTO\n"); return KW_AUTO; }
break       { printf("KW_BREAK\n"); return KW_BREAK; }
case        { printf("KW_CASE\n"); return KW_CASE; }
char        { printf("KW_CHAR\n"); return KW_CHAR; }
const       { printf("KW_CONST\n"); return KW_CONST; }
continue    { printf("KW_CONTINUE\n"); return KW_CONTINUE; }
default     { printf("KW_DEFAULT\n"); return KW_DEFAULT; }
do          { printf("KW_DO\n"); return KW_DO; }
double      { printf("KW_DOUBLE\n"); return KW_DOUBLE; }
else        { printf("KW_ELSE\n"); return KW_ELSE; }
enum        { printf("KW_ENUM\n"); return KW_ENUM; }
extern      { printf("KW_EXTERN\n"); return KW_EXTERN; }
float       { printf("KW_FLOAT\n"); return KW_FLOAT; }
for         { printf("KW_FOR\n"); return KW_FOR; }
goto        { printf("KW_GOTO\n"); return KW_GOTO; }
if          { printf("KW_IF\n"); return KW_IF; }
int         { printf("KW_INT\n"); return KW_INT; }
long        { printf("KW_LONG\n"); return KW_LONG; }
register    { printf("KW_REGISTER\n"); return KW_REGISTER; }
return      { printf("KW_RETURN\n"); return KW_RETURN; }
short       { printf("KW_SHORT\n"); return KW_SHORT; }
signed      { printf("KW_SIGNED\n"); return KW_SIGNED; }
sizeof      { printf("KW_SIZEOF\n"); return KW_SIZEOF; }
static      { printf("KW_STATIC\n"); return KW_STATIC; }
struct      { printf("KW_STRUCT\n"); return KW_STRUCT; }
switch      { printf("KW_SWITCH\n"); return KW_SWITCH; }
typedef     { printf("KW_TYPEDEF\n"); return KW_TYPEDEF; }
union       { printf("KW_UNION\n"); return KW_UNION; }
unsigned    { printf("KW_UNSIGNED\n"); return KW_UNSIGNED; }
void        { printf("KW_VOID\n"); return KW_VOID; }
volatile    { printf("KW_VOLATILE\n"); return KW_VOLATILE; }
while       { printf("KW_WHILE\n"); return KW_WHILE; }

"//".*      { /* ignora comentário de linha */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* ignora comentário de bloco */ }

[a-zA-Z_][a-zA-Z0-9_]* {
    printf("IDENT(%s)\n", yytext);
    return IDENT;
}

[0-9]+(\.[0-9]+)? {
    printf("NUMBER(%s)\n", yytext);
    return NUMBER;
}
   /* --- Operadores de 2 Caracteres --- */

"=="        { printf("TK_OP_IGUAL_COMPARACAO\n"); return TK_OP_IGUAL_COMPARACAO; }
"!="        { printf("TK_OP_DIFERENTE\n"); return TK_OP_DIFERENTE; }
"<="        { printf("TK_OP_MENOR_IGUAL\n"); return TK_OP_MENOR_IGUAL; }
">="        { printf("TK_OP_MAIOR_IGUAL\n"); return TK_OP_MAIOR_IGUAL; }
"&&"        { printf("TK_OP_AND\n"); return TK_OP_AND; }
"||"        { printf("TK_OP_OR\n"); return TK_OP_OR; }
"++"        { printf("TK_OP_INCREMENTO\n"); return TK_OP_INCREMENTO; }
"--"        { printf("TK_OP_DECREMENTO\n"); return TK_OP_DECREMENTO; }
"+="        { printf("TK_OP_MAIS_IGUAL\n"); return TK_OP_MAIS_IGUAL; }
"-="        { printf("TK_OP_MENOS_IGUAL\n"); return TK_OP_MENOS_IGUAL; }
"*="        { printf("TK_OP_MULTIPLICACAO_IGUAL\n"); return TK_OP_MULTIPLICACAO_IGUAL; }
"/="        { printf("TK_OP_DIVISAO_IGUAL\n"); return TK_OP_DIVISAO_IGUAL; }
"%="        { printf("TK_OP_MODULO_IGUAL\n"); return TK_OP_MODULO_IGUAL; }
"<<"        { printf("TK_OP_DESLOCAMENTO_ESQUERDA\n"); return TK_OP_DESLOCAMENTO_ESQUERDA; }
">>"        { printf("TK_OP_DESLOCAMENTO_DIREITA\n"); return TK_OP_DESLOCAMENTO_DIREITA; }
"->"        { printf("TK_OP_PONTEIRO_ACESSO\n"); return TK_OP_PONTEIRO_ACESSO; }

    /* --- Operadores de 1 Caractere --- */

"+"         { printf("TK_OP_SOMA\n"); return TK_OP_SOMA; }
"-"         { printf("TK_OP_SUBTRACAO\n"); return TK_OP_SUBTRACAO; }
"*"         { printf("TK_OP_MULTIPLICACAO\n"); return TK_OP_MULTIPLICACAO; }
"/"         { printf("TK_OP_DIVISAO\n"); return TK_OP_DIVISAO; }
"%"         { printf("TK_OP_MODULO\n"); return TK_OP_MODULO; }
"="         { printf("TK_OP_IGUAL\n"); return TK_OP_IGUAL; }
"<"         { printf("TK_OP_MENOR\n"); return TK_OP_MENOR; }
">"         { printf("TK_OP_MAIOR\n"); return TK_OP_MAIOR; }
"!"         { printf("TK_OP_NAO\n"); return TK_OP_NAO; }
"&"         { printf("TK_OP_E_BIT\n"); return TK_OP_E_BIT; }
"|"         { printf("TK_OP_OU_BIT\n"); return TK_OP_OU_BIT; }
"^"         { printf("TK_OP_XOR_BIT\n"); return TK_OP_XOR_BIT; }
"~"         { printf("TK_OP_NOT_BIT\n"); return TK_OP_NOT_BIT; }
"?"         { printf("TK_OP_TERNARIO\n"); return TK_OP_TERNARIO; }
":"         { printf("TK_OP_DOIS_PONTOS\n"); return TK_OP_DOIS_PONTOS; }
"."         { printf("TK_OP_PONTO\n"); return TK_OP_PONTO; }
","         { printf("TK_OP_VIRGULA\n"); return TK_OP_VIRGULA; }
";"         { printf("TK_OP_PONTO_VIRGULA\n"); return TK_OP_PONTO_VIRGULA; }

"("         { printf("TK_ABRE_PARENTESE\n"); return TK_ABRE_PARENTESE; }
")"         { printf("TK_FECHA_PARENTESE\n"); return TK_FECHA_PARENTESE; }
"{"         { printf("TK_ABRE_CHAVE\n"); return TK_ABRE_CHAVE; }
"}"         { printf("TK_FECHA_CHAVE\n"); return TK_FECHA_CHAVE; }
"["         { printf("TK_ABRE_COLCHETE\n"); return TK_ABRE_COLCHETE; }
"]"         { printf("TK_FECHA_COLCHETE\n"); return TK_FECHA_COLCHETE; }

[ \t\n]+    { /* ignora espaços e quebras de linha */ }

.           { printf("UNKNOWN(%s)\n", yytext); }

%%

int yywrap(void) {
    return 1;
}
