%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include "lex.yy.c"
#include <glib.h>

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

/* used to store the current ID */
char * id = NULL;
/* used to store the current name */
char * nome = NULL;

/* Table of IDs */
GHashTable * idHash;

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

/**
  * Inserts a new id into the hash, returns whether it already
  * had that ID
 */
int insertId(char * id) {
    char * idCopy = strdup(id);
    int hadKey = g_hash_table_insert(idHash, idCopy, strdup(idCopy));
    return !hadKey;
}

/**
  * Returns 1 if does not have one (or both) of the ids
  * 0 if it does have them
 */
int hasBothIds(char * idL, char * idR) {
    void * hasFirst = g_hash_table_lookup(idHash,idL);
    void * hasSecond = g_hash_table_lookup(idHash,idR);
    if (!hasFirst || !hasSecond)
        return 1;
    return 0;
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
      fclose(file);
    }
  }
}

void printGraph(char * content) {
  char * fileName = "graph.dot";
  FILE * file = fopen(fileName,"w");
  if (file) {
      char * header = "graph G {\n\trankdir=\"LR\";\n";
      fwrite(header, 1, strlen(header), file);
      fwrite(content, 1, strlen(content), file);
      char * footer = "}\n";
      fwrite(footer, 1, strlen(footer), file);
      fclose(file);
  }
  else
    puts("Could not open graph.dot!");
}


%}
%union { char * string; int integer; }

/* Tipos de nodos */
%token ARTISTA OBRA EVENTO
/* Tipos de Tags */
%token NOME IDADE FORMACAO PRODUTORAS DATA GENERO DURACAO EDICAO TIPO ID_TAG
/* STRING das Tags e do ID */
%token <string> STRING ID_ARTISTA ID_OBRA ID_EVENTO
/* Valores das Tags*/
%token <integer> INT
/* Tipos de Relações */
%token PRODUZIU APRENDEU COLABOROU PARTICIPOU
/* Tipos das regras da gramática */
%type <string> Nome TagArtista LTagArtista Nodo LTagObra LTagEvento LConteudos Conteudo Relacao TagObra TagEvento Data RArtistaObra RArtistaEvento RArtistaArtista

%%
MvA: LConteudos                       { printGraph($1); }
   ;

LConteudos: Conteudo                  { $$ = $1; }
          | LConteudos Conteudo       { asprintf(&$$,"%s%s",$1,$2); }
          ;

Conteudo: Nodo                         { addFile($1);
                                         int err = insertId(id);
                                         if (err)
                                            yyerror("Id já existente!");
                                         if (nome)
                                            asprintf(&$$, "\t%s [URL=\"%s.html\",label=\"%s\"];\n", id, id, nome);
                                         else
                                            asprintf(&$$, "\t%s [URL=\"%s.html\"];\n", id, id);
                                         id = NULL;
                                         nome = NULL;
                                       }
        | Relacao '.'                  { $$ = $1; }
        ;

Nodo: ARTISTA '{' LTagArtista '}'      { asprintf(&$$,"<h1>Artista</h1>\n%s",$3); clearArtista(); }
    | OBRA '{' LTagObra '}'            { asprintf(&$$,"<h1>Obra</h1>\n%s",$3); clearObra(); }
    | EVENTO '{' LTagEvento '}'        { asprintf(&$$,"<h1>Evento</h1>\n%s",$3); clearEvento(); }
    ;

Nome: NOME ':' STRING                  { nome = $3;
                                         $$ = $3; }
    ;

LTagArtista: ID_TAG ':' ID_ARTISTA      { int err = useTagNode(cID,cARTISTA);
                                          if (err)
                                            yyerror("Id já havia sido definido!");
                                          id = $3;
                                          asprintf(&$$,"%s",formatFieldNode("Id",$3,2));
                                        }
           | LTagArtista ',' TagArtista { asprintf(&$$,"%s\n%s",$1,$3); }
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
                                         asprintf(&$$,"%s",formatFieldNode("Nome",$1,2));
                                       }
          ;

LTagObra: ID_TAG ':' ID_OBRA           { int err = useTagNode(cID,cOBRA);
                                         if (err)
                                            yyerror("Id já havia sido definido!");
                                         id = $3;
                                         asprintf(&$$,"%s",formatFieldNode("Id",$3,2));
                                       }
        | LTagObra ',' TagObra         { asprintf(&$$,"%s\n%s",$1,$3); }
        ;

TagObra: Data                          { int err = useTagNode(cDATA, cOBRA);
                                         if (err)
                                            yyerror("Data já havia sido definida!");
                                         asprintf(&$$,"%s",formatFieldNode("Data",$1,2));
                                       }
       | GENERO ':' STRING             { int err = useTagNode(cGENERO,cOBRA);
                                         if (err)
                                            yyerror("Género já havia sido definido!");
                                         asprintf(&$$,"%s",formatFieldNode("Género",$3,2));
                                       }
       | DURACAO ':' INT               { int err = useTagNode(cDURACAO,cOBRA);
                                         if (err)
                                            yyerror("Duração já havia sido definida!");
                                         char * duracao = intToString($3);
                                         asprintf(&$$,"%s",formatFieldNode("Duração",duracao,2));
                                         free(duracao);
                                       }
       | Nome                          { int err = useTagNode(cNOME,cOBRA);
                                         if (err)
                                            yyerror("Nome já havia sido definido!");
                                         asprintf(&$$,"%s",formatFieldNode("Nome",$1,2));
                                       }
       ;

Data: DATA ':' INT                     { $$ = intToString($3); }
    ;

LTagEvento: ID_TAG ':' ID_EVENTO       { int err = useTagNode(cID,cEVENTO);
                                         if (err)
                                            yyerror("Id já havia sido definido!");
                                         id = $3;
                                         asprintf(&$$,"%s",formatFieldNode("Id",$3,2));
                                       }
          | LTagEvento ',' TagEvento   { asprintf(&$$,"%s\n%s",$1,$3); }
          ;

TagEvento: Data                        { int err = useTagNode(cDATA, cEVENTO);
                                         if (err)
                                            yyerror("Data já havia sido definida!");
                                         asprintf(&$$,"%s",formatFieldNode("Data",$1,2));
                                       }
         | EDICAO ':' INT              { int err = useTagNode(cEDICAO,cEVENTO);
                                         if (err)
                                            yyerror("Edição já havia sido definida!");
                                         char * edicao = intToString($3);
                                         asprintf(&$$,"%s",formatFieldNode("Edição",edicao,2));
                                         free(edicao);
                                        }
         | TIPO ':' STRING              { int err = useTagNode(cTIPO,cEVENTO);
                                          if (err)
                                            yyerror("Tipo já havia sido definido!");
                                          asprintf(&$$,"%s",formatFieldNode("Tipo",$3,2));
                                         }
         | Nome                          { int err = useTagNode(cNOME,cEVENTO);
                                           if (err)
                                             yyerror("Nome já havia sido definido!");
                                           asprintf(&$$,"%s",formatFieldNode("Nome",$1,2));
                                         }
         ;

Relacao: ID_ARTISTA RArtistaObra ID_OBRA       { int err = hasBothIds($1,$3);
                                                 if (err)
                                                    yyerror("Impossível estabelecer relação entre IDs inexistentes!");
                                                 asprintf(&$$,"\t%s -- %s %s;\n",$1, $3, $2);
                                               }
       | ID_ARTISTA RArtistaEvento ID_EVENTO   { int err = hasBothIds($1,$3);
                                                 if (err)
                                                    yyerror("Impossível estabelecer relação entre IDs inexistentes!");
                                                 asprintf(&$$,"\t%s -- %s %s;\n",$1, $3, $2); }
       | ID_ARTISTA RArtistaArtista ID_ARTISTA { int err = hasBothIds($1,$3);
                                                 if (err)
                                                   yyerror("Impossível estabelecer relação entre IDs inexistentes!");
                                                 asprintf(&$$,"\t%s -- %s %s;\n",$1, $3, $2); }
       ;

RArtistaObra: PRODUZIU                   { $$ = "[label=\"produziu\",color=red,penwidth=3.0]"; }
            ;

RArtistaEvento: PARTICIPOU               { $$ = "[label=\"participou em\",color=black,penwidth=3.0]"; }
              ;

RArtistaArtista: APRENDEU                { $$ = "[label=\"aprendeu com\",color=blue,penwidth=3.0]"; }
               | COLABOROU               { $$ = "[label=\"colaborou com\",color=green,penwidth=3.0]"; }
               ;
%%

int yyerror(char *s){
  printf("Erro sintático: %s\n",s);
  return 0;
}

int main(){
    idHash = g_hash_table_new_full(g_str_hash,g_str_equal,free,free);
    yyparse();
    g_hash_table_remove_all(idHash);
    g_hash_table_destroy(idHash);
    return 0;
}
