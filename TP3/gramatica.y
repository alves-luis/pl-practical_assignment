%{
#include <stdio.h>
#include "lex.yy.c"
#define N_ARTISTA_TAGS 5
#define N_EVENTO_TAGS 5
#define N_OBRA_TAGS 5

#define UNUSED 0
#define USED 1

/* Posições da Tags de Artista */
#define cID 0
#define cNOME 1
#define cIDADE 2
#define cFORMACAO 3
#define cPRODUTORAS 4

int artista[N_ARTISTA_TAGS];
int evento[N_EVENTO_TAGS];
int obra[N_OBRA_TAGS];

void clearArtista() {
  for(int i = 0; i < N_ARTISTA_TAGS; i++)
    artista[i] = UNUSED;
}

void clearEvento() {
  for(int i = 0; i < N_EVENTO_TAGS; i++)
    evento[i] = UNUSED;
}

void clearObra() {
  for(int i = 0; i < N_OBRA_TAGS; i++)
    obra[i] = UNUSED;
}

int useIdArtista() {
  if (artista[cID] == UNUSED) {
    artista[cID] = USED;
    return UNUSED;
  }
  return USED;
}

int useNomeArtista() {
  if (artista[cNOME] == UNUSED) {
    artista[cNOME] = USED;
    return UNUSED;
  }
  return USED;
}
%}
%union { char * string; int integer; }

/* Tipos de nodos */
%token ARTISTA OBRA EVENTO
/* Tipos de Tags */
%token NOME IDADE FORMACAO PRODUTORAS DATA GENERO DURACAO EDICAO TIPO ID_TAG
/* STRING das Tags e do ID */
%token <string> STRING ID
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

LTagArtista: Id
           | LTagArtista ',' TagArtista
           ;

Id: ID_TAG ':' ID
  ;

TagArtista: IDADE ':' INT
          | FORMACAO ':' STRING
          | PRODUTORAS ':' STRING
          | Nome
          ;

LTagObra: Id
        | LTagObra ',' TagObra
        ;

TagObra: Data
       | GENERO ':' STRING
       | DURACAO ':' INT
       | Nome
       ;

Data: DATA ':' INT
    ;

LTagEvento: Id
          | LTagEvento ',' TagEvento
          ;

TagEvento: Data
         | EDICAO ':' INT
         | TIPO ':' STRING
         | Nome
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
