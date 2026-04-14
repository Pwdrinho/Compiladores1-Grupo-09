%{
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

auto	        { printf("KW_AUTO\n"); return KW_AUTO;}
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

/* --- 2. Operadores de 2 Caracteres (Compostos) --- */
"=="            { return TK_OP_IGUAL_COMPARACAO; }
"!="            { return TK_OP_DIFERENTE; }
"<="            { return TK_OP_MENOR_IGUAL; }
">="            { return TK_OP_MAIOR_IGUAL; }
"&&"            { return TK_OP_AND; }
"||"            { return TK_OP_OR; }
"++"            { return TK_OP_INCREMENTO; }
"--"            { return TK_OP_DECREMENTO; }
"+="            { return TK_OP_MAIS_IGUAL; }
"-="            { return TK_OP_MENOS_IGUAL; }
"*="            { return TK_OP_MULTIPLICACAO_IGUAL; }
"/="            { return TK_OP_DIVISAO_IGUAL; }
"%="            { return TK_OP_MODULO_IGUAL; }
"<<"            { return TK_OP_DESLOCAMENTO_ESQUERDA; }
">>"            { return TK_OP_DESLOCAMENTO_DIREITA; }
"->"            { return TK_OP_PONTEIRO_ACESSO; }

/* --- 3. Operadores de 1 Caractere (Simples) --- */
"+"             { return  TK_OP_SOMA; }
"-"             { return  TK_OP_SUBTRACAO; }
"*"             { return  TK_OP_MULTIPLICACAO; }
"/"             { return  TK_OP_DIVISAO; }
"%"             { return  TK_OP_MODULO; }
"="             { return  TK_OP_IGUAL; }
"<"             { return  TK_OP_MENOR; }
">"             { return  TK_OP_MAIOR; }
"!"             { return  TK_OP_NÃO; }
"&"             { return  TK_OP_E_BIT; }
"|"             { return  TK_OP_OU_BIT }
"^"             { return  TK_OP_XOR_BIT }
"~"             { return  TK_OP_NOT_BIT }
"?"             { return  TK_OP_TERNARIO; }
":"             { return  TK_OP_DOIS_PONTOS }
"."             { return  TK_OP_PONTO }
","             { return  TK_OP_VIRGULA }

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
