%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <gmodule.h>
 // Hash table com tag as key e e número e TagValue
GHashTable * tagCount = NULL;
 // Lista com tags de cada artigo
GSList * tags = NULL;
 // Lista com categorias de cada artigo
GSList * categories = NULL;
char * idPost = NULL;
char * title = NULL;
char * date = NULL;
char * text = NULL;

typedef struct tagValue {
	int count;
	GSList * idPosts;
} * TagValue;
int textSize = 0;

void printCategoriaInNorm(void * tag, void * data) {
	fprintf((FILE *) data, "<category>%s</category> ", (char *) tag);
}

void printTagInNorm(void * tag, void * data) {
	fprintf((FILE *) data, "<tag>%s</tag> ", (char *) tag);
}

void printTaginHTML(void * tag, void * data) {
	fprintf((FILE *) data, "<li>%s</li>\n",(char * )tag);
}

void printCategoriesInHTML(void * category, void* data){
	fprintf((FILE *)data, "<li>%s</li>\n",(char *)category);
}

void htmlInit(FILE * f) {
	fprintf(f,"<html><head><meta charset='UTF-8'/> </head><body>");
}

void formatPrintNorm() {
	char * fName = malloc(sizeof(char)*512);
	sprintf(fName,"%s.norm",idPost);
	FILE * normalized= fopen(fName,"w");
	fprintf(normalized,"<pub id=\"%s\">\n",idPost);
	fprintf(normalized,"\t<title>%s</title>\n",title);
	fprintf(normalized,"\t<author_date>%s</author_date>\n",date);
	fprintf(normalized,"\t<tags>\n\t\t");
	g_slist_foreach(tags,printTagInNorm,normalized);
	fprintf(normalized,"\n\t</tags>\n");
	fprintf(normalized,"\t<categories>\n\t\t");
	g_slist_foreach(categories,printCategoriaInNorm,normalized);
	fprintf(normalized,"\n\t</categories>\n");
	fprintf(normalized,"\t<text>\n");
	fprintf(normalized,"%s\n",text);
	fprintf(normalized,"\t</text>\n");
	fprintf(normalized,"</pub>\n");
	fclose(normalized);
	free(fName);
}
void formatPrintHTML(){
	// now we create the file with html
	char * fileName = malloc(sizeof(char)*512);
	sprintf(fileName,"%s.html",idPost);
	FILE * postHtml = fopen(fileName,"w");
	htmlInit(postHtml);
	fprintf(postHtml,"<h1>%s</h1>\n",idPost + 5);
	fprintf(postHtml,"<h2>%s</h2>\n",title);
	fprintf(postHtml,"<b>Author - Date: </b>%s\n",date);
	fprintf(postHtml,"<p></p><b>Tags:</b><ul>\n");
	g_slist_foreach(tags,printTaginHTML,postHtml);
	fprintf(postHtml,"</ul>\n");
	fprintf(postHtml,"<p></p><b>Categoria:</b><ul>\n");
	g_slist_foreach(categories,printCategoriesInHTML,postHtml);
	fprintf(postHtml,"</ul>\n");
	fprintf(postHtml,"<p>%s</p>",text);

	fclose(postHtml);
	free(fileName);
}

void freeString(void * string) {
	free((char *)string);
}

void addIdsToHash(void * tag, void * id) {
	TagValue value = g_hash_table_lookup(tagCount,(char *) tag);
	if (value)
		value->idPosts = g_slist_prepend(value->idPosts,(char *)id);
}

%}

%x PUB TAG ID CATEG TITLE DATE TEXT
dig [0-9]


%%
\<pub\>			{ BEGIN PUB; }

<PUB>\</pub\>	{ BEGIN INITIAL; }
<PUB>#TAG: 		{ tags = NULL; BEGIN TAG; }
<PUB>#DATE:" "\[[^\]]+\]" " { BEGIN DATE; }
<PUB>.|\n		{;}

<TAG>#ID:		{ BEGIN ID; }
<TAG>tag:\{[^}]+\}	{
	yytext[yyleng-1]=0;
	char* tag_name = strdup(yytext+5);
	TagValue value = g_hash_table_lookup(tagCount,tag_name);
	if (value) { // if already exists, increase count
		value->count = (value->count)+1;
	}
	else { // else create new entry in hash count
		value = (TagValue) malloc(sizeof(struct tagValue));
		value->count = 1;
		value->idPosts = NULL;
		g_hash_table_insert(tagCount,tag_name,value);
	}
	tags = g_slist_prepend(tags,tag_name);
}
<TAG>.|\n 		{;}

<ID>\}\n		{ categories = NULL; BEGIN CATEG; }
<ID>\{post-{dig}+	{
	idPost=strdup(yytext+1);
	// add ID to each tag
	g_slist_foreach(tags,addIdsToHash,idPost);}
<ID>.				{;}

<CATEG>\n\n		{ BEGIN TITLE; }
<CATEG>[A-Z][a-z]+	{
	char * category = strdup(yytext);
	categories = g_slist_prepend(categories,category);
}
<CATEG>.|\n 	{;}

<TITLE>\n		{BEGIN PUB;}
<TITLE>[^\n]+	{title = strdup(yytext);}

<DATE>\n		{
	if (text) {
		free(text);
	}
	text = malloc(sizeof(char)*1024);
	text[0] = '\0';
	textSize = 1024;
	BEGIN TEXT;
}
<DATE>.+		{date = strdup(yytext);}

<TEXT>\nPartilhe" "este" "Artigo\n { formatPrintNorm();formatPrintHTML();BEGIN PUB;}
<TEXT>\nEtiquetas: 				   { formatPrintNorm();formatPrintHTML();BEGIN PUB;}
<TEXT>^\[.*\] { ;}
<TEXT>.*|\n							{
	int size = strlen(text)+yyleng+1;
	if (size > textSize) {
		char * newText = malloc(sizeof(char)*textSize*2);
		strcpy(newText,text);
		strcat(newText,yytext);
		free(text);
		text = newText;
		textSize *= 2;
	}
	else {
		strcat(text,yytext);
	}
}
.|\n 								{;}
%%

int yywrap() {
	return 1;
}

void printPostIdInTagIndex(void * id, void * file) {
	fprintf((FILE *)file,"<li><a href=\"%s.html\">%s</a></li>\n",(char *)id, (char *)id);
}

void printTagIndex(void * key, void * value, void * file) {
	fprintf((FILE *)file,"<p><b>%s - %d</b></p>\n<ul>",(char *) key, ((TagValue) value)->count);
	g_slist_foreach(((TagValue) value)->idPosts,printPostIdInTagIndex,file);
	fprintf((FILE *)file,"</ul>\n");
}

void generateIndex() {
	FILE * tagsIndexFile = fopen("tags.html","w");
	g_hash_table_foreach(tagCount, printTagIndex, tagsIndexFile);
}

int main(int argc, char * argv[]) {
	tagCount = g_hash_table_new(g_str_hash,g_str_equal);
	yylex();
	generateIndex();
	return 0;
}
