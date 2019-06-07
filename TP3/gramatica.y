%{
#include <stdio.h>
#include "lex.yy.c"
%}
%union { char * string; int integer; }

/* Tipos de nodos */
%token ARTISTA OBRA EVENTO
/* Tipos de Tags */
%token NOME IDADE FORMACAO PRODUTORAS DATA GENERO DURACAO EDICAO TIPO
/* STRING das Tags */
%token <string> STRING
/* Valores das Tags*/
%token <integer> INT
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

Nodo: ARTISTA '{' LTagArtista '}'      { printf("Estou num ARTISTA!\n"); }
    | OBRA '{' LTagObra '}'            { printf("Estou numa OBRA!\n"); }
    | EVENTO '{' LTagEvento '}'        { printf("Estou num EVENTO!\n"); }
    ;

Nome: NOME ':' STRING
    ;

LTagArtista: Nome
           | LTagArtista ',' TagArtista
           ;

TagArtista: IDADE ':' INT
          | FORMACAO ':' STRING
          | PRODUTORAS ':' STRING
          ;

LTagObra: Nome
        | LTagObra ',' TagObra
        ;

TagObra: Data
       | GENERO ':' STRING
       | DURACAO ':' INT
       ;

Data: DATA ':' INT
    ;

LTagEvento: Nome
          | LTagEvento ',' TagEvento
          ;

TagEvento: Data
         | EDICAO ':' INT
         | TIPO ':' STRING
         ;

Relacao: STRING Ligacao STRING { printf("Estou  numa RELAÇÃO!\n"); }
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
