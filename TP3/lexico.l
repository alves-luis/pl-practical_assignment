%{
#include "y.tab.h"
#include <stdio.h>
%}

%%
(?i:Artista)             { return ARTISTA; }
(?i:Obra)                { return OBRA; }
(?i:Evento)              { return EVENTO; }
(?i:Nome)                { return NOME; }
(?i:Idade)               { return IDADE; }
(?i:Formação)            { return FORMACAO; }
(?i:Produtoras)          { return PRODUTORAS; }
(?i:Data)                { return DATA; }
(?i:Genero)              { return GENERO; }
(?i:Duração)             { return DURACAO; }
(?i:Edição)              { return EDICAO; }
(?i:Tipo)                { return TIPO; }
(?i:produziu)            { return PRODUZIU; }
(?i:aprendeuCom)         { return APRENDEU; }
(?i:colaborouCom)        { return COLABOROU; }
(?i:participouEm)        { return PARTICIPOU; }
[;.:{}]                  { return yytext[0];}
\'[^\']+\'               {
                           yytext[yyleng-1] = '\0';
                           yylval.string = yytext + 1;
                           return VALOR;
                         }
.|\n                     { ; }

%%

int yywrap(){
  return 1;
}
