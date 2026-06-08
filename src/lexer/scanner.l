%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

/*
 * Controla se o lexer deve imprimir os tokens reconhecidos.
 *
 * Para testar só o scanner, você pode trocar para 1.
 * Para integrar com o parser/AST, mantenha 0 para a saída não ficar poluída.
 */
#ifndef DEBUG_LEXER
#define DEBUG_LEXER 0
#endif

#define LEX_PRINT(...)              \
    do {                            \
        if (DEBUG_LEXER) {          \
            printf(__VA_ARGS__);    \
        }                           \
    } while (0)

/*
 * Copia o texto atual reconhecido pelo lexer.
 *
 * yytext é reutilizado pelo Flex a cada novo token.
 * Por isso, quando precisamos guardar o texto no parser,
 * fazemos uma cópia dinâmica da string.
 */
static char *copiar_yytext(const char *texto) {
    char *copia = malloc(strlen(texto) + 1);

    if (copia == NULL) {
        return NULL;
    }

    strcpy(copia, texto);
    return copia;
}
%}

/*
 * Evita warnings de funções geradas pelo Flex que não usamos.
 */
%option noinput nounput

%%

auto        { LEX_PRINT("KW_AUTO\n"); return KW_AUTO; }
break       { LEX_PRINT("KW_BREAK\n"); return KW_BREAK; }
case        { LEX_PRINT("KW_CASE\n"); return KW_CASE; }
char        { LEX_PRINT("KW_CHAR\n"); return KW_CHAR; }
const       { LEX_PRINT("KW_CONST\n"); return KW_CONST; }
continue    { LEX_PRINT("KW_CONTINUE\n"); return KW_CONTINUE; }
default     { LEX_PRINT("KW_DEFAULT\n"); return KW_DEFAULT; }
do          { LEX_PRINT("KW_DO\n"); return KW_DO; }
double      { LEX_PRINT("KW_DOUBLE\n"); return KW_DOUBLE; }
else        { LEX_PRINT("KW_ELSE\n"); return KW_ELSE; }
enum        { LEX_PRINT("KW_ENUM\n"); return KW_ENUM; }
extern      { LEX_PRINT("KW_EXTERN\n"); return KW_EXTERN; }
float       { LEX_PRINT("KW_FLOAT\n"); return KW_FLOAT; }
for         { LEX_PRINT("KW_FOR\n"); return KW_FOR; }
goto        { LEX_PRINT("KW_GOTO\n"); return KW_GOTO; }
if          { LEX_PRINT("KW_IF\n"); return KW_IF; }
int         { LEX_PRINT("KW_INT\n"); return KW_INT; }
long        { LEX_PRINT("KW_LONG\n"); return KW_LONG; }
register    { LEX_PRINT("KW_REGISTER\n"); return KW_REGISTER; }
return      { LEX_PRINT("KW_RETURN\n"); return KW_RETURN; }
short       { LEX_PRINT("KW_SHORT\n"); return KW_SHORT; }
signed      { LEX_PRINT("KW_SIGNED\n"); return KW_SIGNED; }
sizeof      { LEX_PRINT("KW_SIZEOF\n"); return KW_SIZEOF; }
static      { LEX_PRINT("KW_STATIC\n"); return KW_STATIC; }
struct      { LEX_PRINT("KW_STRUCT\n"); return KW_STRUCT; }
switch      { LEX_PRINT("KW_SWITCH\n"); return KW_SWITCH; }
typedef     { LEX_PRINT("KW_TYPEDEF\n"); return KW_TYPEDEF; }
union       { LEX_PRINT("KW_UNION\n"); return KW_UNION; }
unsigned    { LEX_PRINT("KW_UNSIGNED\n"); return KW_UNSIGNED; }
void        { LEX_PRINT("KW_VOID\n"); return KW_VOID; }
volatile    { LEX_PRINT("KW_VOLATILE\n"); return KW_VOLATILE; }
while       { LEX_PRINT("KW_WHILE\n"); return KW_WHILE; }

"//".*      { /* Ignora comentário de linha. */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* Ignora comentário de bloco. */ }

[a-zA-Z_][a-zA-Z0-9_]* {
    /*
     * Envia o nome do identificador para o parser.
     * Exemplo: x, idade, contador.
     */
    yylval.str = copiar_yytext(yytext);
    LEX_PRINT("IDENT(%s)\n", yytext);
    return IDENT;
}

[0-9]+(\.[0-9]+)? {
    /*
     * Envia o número como texto para o parser.
     * A análise semântica pode decidir depois se é int ou float.
     */
    yylval.str = copiar_yytext(yytext);
    LEX_PRINT("NUMBER(%s)\n", yytext);
    return NUMBER;
}

    /* Operadores de 2 caracteres. */

"=="        { LEX_PRINT("TK_OP_IGUAL_COMPARACAO\n"); return TK_OP_IGUAL_COMPARACAO; }
"!="        { LEX_PRINT("TK_OP_DIFERENTE\n"); return TK_OP_DIFERENTE; }
"<="        { LEX_PRINT("TK_OP_MENOR_IGUAL\n"); return TK_OP_MENOR_IGUAL; }
">="        { LEX_PRINT("TK_OP_MAIOR_IGUAL\n"); return TK_OP_MAIOR_IGUAL; }
"&&"        { LEX_PRINT("TK_OP_AND\n"); return TK_OP_AND; }
"||"        { LEX_PRINT("TK_OP_OR\n"); return TK_OP_OR; }
"++"        { LEX_PRINT("TK_OP_INCREMENTO\n"); return TK_OP_INCREMENTO; }
"--"        { LEX_PRINT("TK_OP_DECREMENTO\n"); return TK_OP_DECREMENTO; }
"+="        { LEX_PRINT("TK_OP_MAIS_IGUAL\n"); return TK_OP_MAIS_IGUAL; }
"-="        { LEX_PRINT("TK_OP_MENOS_IGUAL\n"); return TK_OP_MENOS_IGUAL; }
"*="        { LEX_PRINT("TK_OP_MULTIPLICACAO_IGUAL\n"); return TK_OP_MULTIPLICACAO_IGUAL; }
"/="        { LEX_PRINT("TK_OP_DIVISAO_IGUAL\n"); return TK_OP_DIVISAO_IGUAL; }
"%="        { LEX_PRINT("TK_OP_MODULO_IGUAL\n"); return TK_OP_MODULO_IGUAL; }
"<<"        { LEX_PRINT("TK_OP_DESLOCAMENTO_ESQUERDA\n"); return TK_OP_DESLOCAMENTO_ESQUERDA; }
">>"        { LEX_PRINT("TK_OP_DESLOCAMENTO_DIREITA\n"); return TK_OP_DESLOCAMENTO_DIREITA; }
"->"        { LEX_PRINT("TK_OP_PONTEIRO_ACESSO\n"); return TK_OP_PONTEIRO_ACESSO; }

    /* Operadores de 1 caractere. */

"+"         { LEX_PRINT("TK_OP_SOMA\n"); return TK_OP_SOMA; }
"-"         { LEX_PRINT("TK_OP_SUBTRACAO\n"); return TK_OP_SUBTRACAO; }
"*"         { LEX_PRINT("TK_OP_MULTIPLICACAO\n"); return TK_OP_MULTIPLICACAO; }
"/"         { LEX_PRINT("TK_OP_DIVISAO\n"); return TK_OP_DIVISAO; }
"%"         { LEX_PRINT("TK_OP_MODULO\n"); return TK_OP_MODULO; }
"="         { LEX_PRINT("TK_OP_IGUAL\n"); return TK_OP_IGUAL; }
"<"         { LEX_PRINT("TK_OP_MENOR\n"); return TK_OP_MENOR; }
">"         { LEX_PRINT("TK_OP_MAIOR\n"); return TK_OP_MAIOR; }
"!"         { LEX_PRINT("TK_OP_NAO\n"); return TK_OP_NAO; }
"&"         { LEX_PRINT("TK_OP_E_BIT\n"); return TK_OP_E_BIT; }
"|"         { LEX_PRINT("TK_OP_OU_BIT\n"); return TK_OP_OU_BIT; }
"^"         { LEX_PRINT("TK_OP_XOR_BIT\n"); return TK_OP_XOR_BIT; }
"~"         { LEX_PRINT("TK_OP_NOT_BIT\n"); return TK_OP_NOT_BIT; }
"?"         { LEX_PRINT("TK_OP_TERNARIO\n"); return TK_OP_TERNARIO; }
":"         { LEX_PRINT("TK_OP_DOIS_PONTOS\n"); return TK_OP_DOIS_PONTOS; }
"."         { LEX_PRINT("TK_OP_PONTO\n"); return TK_OP_PONTO; }
","         { LEX_PRINT("TK_OP_VIRGULA\n"); return TK_OP_VIRGULA; }
";"         { LEX_PRINT("TK_OP_PONTO_VIRGULA\n"); return TK_OP_PONTO_VIRGULA; }

"("         { LEX_PRINT("TK_ABRE_PARENTESE\n"); return TK_ABRE_PARENTESE; }
")"         { LEX_PRINT("TK_FECHA_PARENTESE\n"); return TK_FECHA_PARENTESE; }
"{"         { LEX_PRINT("TK_ABRE_CHAVE\n"); return TK_ABRE_CHAVE; }
"}"         { LEX_PRINT("TK_FECHA_CHAVE\n"); return TK_FECHA_CHAVE; }
"["         { LEX_PRINT("TK_ABRE_COLCHETE\n"); return TK_ABRE_COLCHETE; }
"]"         { LEX_PRINT("TK_FECHA_COLCHETE\n"); return TK_FECHA_COLCHETE; }

[ \t\n\r]+ { /* Ignora espaços, tabs e quebras de linha. */ }

.           { printf("UNKNOWN(%s)\n", yytext); }

%%

int yywrap(void) {
    return 1;
}