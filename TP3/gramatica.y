%{
#include <stdio.h>
#include "lex.yy.c"
%}
%union { char * string; }

/* Tipos de nodos */
%token ARTISTA OBRA EVENTO
/* Tipos de Tags */
%token NOME IDADE FORMACAO PRODUTORAS DATA GENERO DURACAO EDICAO TIPO
/* Valor das Tags */
%token <string> VALOR
/* Tipos de Relações */
%token PRODUZIU APRENDEU COLABOROU PARTICIPOU

%%
MvA: LConteudos
   ;

LConteudos: Conteudo
          | LConteudos Conteudo
          ;

Conteudo: Nodo
        | Relacao
        ;

Nodo: ARTISTA '{' Nome LTagArtista
    | OBRA '{' Nome LTagObra
    | EVENTO '{' Nome LTagEvento
    ;

Nome: NOME ':' VALOR ';'
    ;

LTagArtista: '}'
           | TagArtista '}'
           | LTagArtista TagArtista
           ;

TagArtista: AtributoArtista ':' VALOR ';'
          ;

AtributoArtista: IDADE
               | FORMACAO
               | PRODUTORAS
               ;

LTagObra: '}'
        | TagObra '}'
        | LTagObra TagObra
        ;

TagObra: AtributoObra ':' VALOR ';'
         ;

AtributoObra: DATA
            | GENERO
            | DURACAO
            ;

LTagEvento: '}'
          | TagEvento '}'
          | LTagEvento TagEvento
          ;

TagEvento: AtributoEvento ':' VALOR ';'
         ;

AtributoEvento: EDICAO
              | DATA
              | TIPO
              ;

Relacao: VALOR Ligacao VALOR '.'
       ;

Ligacao: PRODUZIU
       | APRENDEU
       | COLABOROU
       | PARTICIPOU
       ;
%%

int yyerror(char *s){
  printf("ERRO SINTÁTICO: %s\n",s);
  return 0;
}

int main(){
  yyparse();
  return 0;
}
