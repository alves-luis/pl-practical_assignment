%{
#include <stdio.h>
#include <string.h>
#include "lex.yy.c"

int yyerror(char * s);

/* Nº de tags de cada nodo */
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

/* Posições das Tags de Evento */
#define cDATA 2
#define cTIPO 3
#define cEDICAO 4

/* Posições das Tags de Obra */
#define cGENERO 3
#define cDURACAO 4

/* Tipos de Nodos */
#define cARTISTA 0
#define cEVENTO 1
#define cOBRA 2

int artista[N_ARTISTA_TAGS];
int evento[N_EVENTO_TAGS];
int obra[N_OBRA_TAGS];

/* used to store the ID */
char * id;

/**
  * Clears the array of used tags in artista
 */
void clearArtista() {
  for(int i = 0; i < N_ARTISTA_TAGS; i++)
    artista[i] = UNUSED;
}

/**
  * Clears the array of used tags in evento
 */
void clearEvento() {
  for(int i = 0; i < N_EVENTO_TAGS; i++)
    evento[i] = UNUSED;
}

/**
  * Clears the array of used tags in obra
 */
void clearObra() {
  for(int i = 0; i < N_OBRA_TAGS; i++)
    obra[i] = UNUSED;
}

/**
  * Marks the tag of a given a node as used
  * @return 1 if was already used, 0 if not
 */
int useTagNode(int tag, int node) {
  int * usedArray;
  int maxSize = 0;

  switch (node) {
    case cARTISTA: usedArray = artista;
                   maxSize = N_ARTISTA_TAGS;
                   break;
    case cEVENTO:  usedArray = evento;
                   maxSize = N_EVENTO_TAGS;
                   break;
    case cOBRA:    usedArray = obra;
                   maxSize = N_OBRA_TAGS;
                   break;
  }

  if (tag >= maxSize)
    return 1;

  if (usedArray[tag] == UNUSED) {
    usedArray[tag] = USED;
    return UNUSED;
  }
  return USED;
}

char * formatFieldNode(char * title, char * content, int header) {
  char * result;
  asprintf(&result,"\t<h%d>%s</h%d>\n\t\t<p>%s</p>\n", header, title, header, content);
  return result;
}

char * intToString(int num) {
  char result[12];
  sprintf(result,"%d",num);
  return strdup(result);
}

void addFile(char * fileContent) {
  if (id) {
    char fileName[20];
    sprintf(fileName,"%s.html",id);
    FILE * file = fopen(fileName,"w");
    if (file) {
      fwrite(fileContent, 1, strlen(fileContent), file);
    }
  }
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

%type <string> Nome TagArtista LTagArtista Nodo Id LTagObra LTagEvento

%%
MvA: LConteudos
   ;

LConteudos: Conteudo
          | LConteudos Conteudo
          ;

Conteudo: Nodo                         { addFile($1); id = NULL; }
        | Relacao
        ;

Nodo: ARTISTA '{' LTagArtista '}'      { asprintf(&$$,"<h1>Artista</h1>\n%s",$3); clearArtista(); }
    | OBRA '{' LTagObra '}'            { asprintf(&$$,"<h1>Obra</h1>\n%s",$3); clearObra(); }
    | EVENTO '{' LTagEvento '}'        { asprintf(&$$,"<h1>Evento</h1>\n%s",$3); clearEvento(); }
    ;

Nome: NOME ':' STRING                  { $$ = $3; }
    ;

LTagArtista: Id                         { int err = useTagNode(cID,cARTISTA);
                                          if (err)
                                            yyerror("Id já havia sido definido!");
                                          asprintf(&$$,"%s",formatFieldNode("Id",$1,2));
                                        }
           | LTagArtista ',' TagArtista { asprintf(&$$,"%s\n%s",$1,$3); }
           ;

Id: ID_TAG ':' ID                      {  id = $3;
                                          $$ = $3;
                                       }
  ;

TagArtista: IDADE ':' INT              { int err = useTagNode(cIDADE,cARTISTA);
                                         if (err)
                                            yyerror("Idade já havia sido definida!");
                                         char * idade = intToString($3);
                                         asprintf(&$$,"%s",formatFieldNode("Idade",idade,2));
                                         free(idade);
                                       }
          | FORMACAO ':' STRING        { int err = useTagNode(cFORMACAO,cARTISTA);
                                         if (err)
                                            yyerror("Formação já havia sido definida!");
                                         asprintf(&$$,"%s",formatFieldNode("Formação",$3,2));
                                       }
          | PRODUTORAS ':' STRING      { int err = useTagNode(cPRODUTORAS,cARTISTA);
                                         if (err)
                                            yyerror("Produtoras já haviam sido definidas!");
                                         asprintf(&$$,"%s",formatFieldNode("Produtoras",$3,2));
                                       }
          | Nome                       { int err = useTagNode(cNOME, cARTISTA);
                                         if (err)
                                            yyerror("Nome já havia sido definido!");
                                         ;
                                         asprintf(&$$,"%s",formatFieldNode("Nome",$1,2));
                                       }
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

Relacao: ID Ligacao ID {  }
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
