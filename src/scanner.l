%{
#include <stdio.h>

enum tokens {
    KW_AUTO = 258, KW_BREAK, KW_CASE, KW_CHAR, KW_CONST, KW_CONTINUE, KW_DEFAULT,
    KW_DO, KW_DOUBLE, KW_ELSE, KW_ENUM, KW_EXTERN, KW_FLOAT, KW_FOR, KW_GOTO,
    KW_IF, KW_INT, KW_LONG, KW_REGISTER, KW_RETURN, KW_SHORT, KW_SIGNED,
    KW_SIZEOF, KW_STATIC, KW_STRUCT, KW_SWITCH, KW_TYPEDEF, KW_UNION,
    KW_UNSIGNED, KW_VOID, KW_VOLATILE, KW_WHILE,
    TK_OP_IGUAL_COMPARACAO, TK_OP_DIFERENTE, TK_OP_MENOR_IGUAL, TK_OP_MAIOR_IGUAL,
    TK_OP_AND, TK_OP_OR, TK_OP_INCREMENTO, TK_OP_DECREMENTO, TK_OP_MAIS_IGUAL,
    TK_OP_MENOS_IGUAL, TK_OP_MULTIPLICACAO_IGUAL, TK_OP_DIVISAO_IGUAL,
    TK_OP_MODULO_IGUAL, TK_OP_DESLOCAMENTO_ESQUERDA, TK_OP_DESLOCAMENTO_DIREITA,
    TK_OP_PONTEIRO_ACESSO, TK_OP_SOMA, TK_OP_SUBTRACAO, TK_OP_MULTIPLICACAO,
    TK_OP_DIVISAO, TK_OP_MODULO, TK_OP_IGUAL, TK_OP_MENOR, TK_OP_MAIOR,
    TK_OP_NAO, TK_OP_E_BIT, TK_OP_OU_BIT, TK_OP_XOR_BIT, TK_OP_NOT_BIT,
    TK_OP_TERNARIO, TK_OP_DOIS_PONTOS, TK_OP_PONTO, TK_OP_VIRGULA
};

%}

/* Definições de padrões de token e ações */
%%

auto	        { printf("KW_AUTO\n"); }
break	        { printf("KW_BREAK\n"); }
case	        { printf("KW_CASE\n"); }
char	        { printf("KW_CHAR\n"); }
const	        { printf("KW_CONST\n"); }
continue	    { printf("KW_CONTINUE\n"); }
default	        { printf("KW_DEFAULT\n"); }
do	            { printf("KW_DO\n"); }
double	        { printf("KW_DOUBLE\n"); }
else	        { printf("KW_ELSE\n"); }
enum	        { printf("KW_ENUM\n"); }
extern	        { printf("KW_EXTERN\n"); }
float	        { printf("KW_FLOAT\n"); }
for	            { printf("KW_FOR\n"); }
goto	        { printf("KW_GOTO\n"); }
if	            { printf("KW_IF\n"); }
int	            { printf("KW_INT\n"); }
long	        { printf("KW_LONG\n"); }
register	    { printf("KW_REGISTER\n"); }
return	        { printf("KW_RETURN\n"); }
short	        { printf("KW_SHORT\n"); }
signed	        { printf("KW_SIGNED\n"); }
sizeof	        { printf("KW_SIZEOF\n"); }
static	        { printf("KW_STATIC\n"); }
struct	        { printf("KW_STRUCT\n"); }
switch	        { printf("KW_SWITCH\n"); }
typedef	        { printf("KW_TYPEDEF\n"); }
union	        { printf("KW_UNION\n"); }
unsigned	    { printf("KW_UNSIGNED\n"); }
void	        { printf("KW_VOID\n"); }
volatile	    { printf("KW_VOLATILE\n"); }
while	        { printf("KW_WHILE\n"); }

"//".*     { /* Ignorar comentários de linha */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* Ignorar comentários de bloco */ }

[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENT(%s)\n", yytext); }

[0-9]+(\.[0-9]+)?  { printf("NUMBER(%s)\n", yytext); }

    /* --- Operadores de 2 Caracteres --- */
"=="            {printf("TK_OP_IGUAL_COMPARACAO\n"); }
"!="            {printf("TK_OP_DIFERENTE\n"); }
"<="            {printf("TK_OP_MENOR_IGUAL\n"); }
">="            {printf("TK_OP_MAIOR_IGUAL\n"); }
"&&"            {printf("TK_OP_AND\n"); }
"||"            {printf("TK_OP_OR\n"); }
"++"            {printf("TK_OP_INCREMENTO\n"); }
"--"            {printf("TK_OP_DECREMENTO\n"); }
"+="            {printf("TK_OP_MAIS_IGUAL\n"); }
"-="            {printf("TK_OP_MENOS_IGUAL\n"); }
"*="            {printf("TK_OP_MULTIPLICACAO_IGUAL\n"); }
"/="            {printf("TK_OP_DIVISAO_IGUAL\n"); }
"%="            {printf("TK_OP_MODULO_IGUAL\n"); }
"<<"            {printf("TK_OP_DESLOCAMENTO_ESQUERDA\n"); }
">>"            {printf("TK_OP_DESLOCAMENTO_DIREITA\n"); }
"->"            {printf("TK_OP_PONTEIRO_ACESSO\n"); }

    /* --- Operadores de 1 Caractere --- */
"+"             {printf("TK_OP_SOMA\n"); }
"-"             {printf("TK_OP_SUBTRACAO\n"); }
"*"             {printf("TK_OP_MULTIPLICACAO\n"); }
"/"             {printf("TK_OP_DIVISAO\n"); }
"%"             {printf("TK_OP_MODULO\n"); }
"="             {printf("TK_OP_IGUAL\n"); }
"<"             {printf("TK_OP_MENOR\n"); }
">"             {printf("TK_OP_MAIOR\n"); }
"!"             {printf("TK_OP_NAO\n"); }
"&"             {printf("TK_OP_E_BIT\n"); }
"|"             {printf("TK_OP_OU_BIT\n"); }
"^"             {printf("TK_OP_XOR_BIT\n"); }
"~"             {printf("TK_OP_NOT_BIT\n"); }
"?"             {printf("TK_OP_TERNARIO\n"); }
":"             {printf("TK_OP_DOIS_PONTOS\n"); }
"."             {printf("TK_OP_PONTO\n"); }
","             {printf("TK_OP_VIRGULA\n"); }
";"             {printf("TK_OP_PONTO_VIRGULA\n"); }

    /* (type) definir regra depois*/
    /* colocar todos os tipos*/

[ \t\n]+  { /* Não faz nada */ }

.  { printf("UNKNOWN(%s)\n", yytext); }

%%

/* Função auxiliar do Flex (quando termina o arquivo de entrada) */
int yywrap(void) {
    return 1;
}

/* Função principal: executa o analisador léxico */
int main(void) {
    yylex();
    return 0;
}
