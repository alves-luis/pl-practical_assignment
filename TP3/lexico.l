%{
#include "y.tab.h"
#include <stdio.h>
%}

numero                   [0-9]
INT                      {numero}+

%%
(?i:Artista)             { return ARTISTA; }
(?i:Obra)                { return OBRA; }
(?i:Evento)              { return EVENTO; }
(?i:Nome)                { return NOME; }
(?i:Idade)               { return IDADE; }
(?i:Formacao)            { return FORMACAO; }
(?i:Produtoras)          { return PRODUTORAS; }
(?i:Data)                { return DATA; }
(?i:Genero)              { return GENERO; }
(?i:Duracao)             { return DURACAO; }
(?i:Edicao)              { return EDICAO; }
(?i:Tipo)                { return TIPO; }
(?i:produziu)            { return PRODUZIU; }
(?i:aprendeuCom)         { return APRENDEU; }
(?i:colaborouCom)        { return COLABOROU; }
(?i:participouEm)        { return PARTICIPOU; }
{INT}                    { yylval.integer = atoi(yytext); return INT;}
\"[^"]+\"                {
                           yytext[yyleng-1] = '\0';
                           yylval.string = yytext + 1;
                           return STRING;
                         }
[,:{}]                   { return yytext[0];}
.|\n                     { ; }

%%

int yywrap(){
  return 1;
}
