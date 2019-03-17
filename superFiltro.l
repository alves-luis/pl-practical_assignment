%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <gmodule.h>
GHashTable * tagCount = NULL;
GSList * tags = NULL;
GSList * categories = NULL;
char * idPost = NULL;
char * title = NULL;
char * date = NULL;
char * text = NULL;
int textSize = 0;

void freeString(void * string) {
	free((char *)string);
}

void imprime(void * tag, void * data){
	printf("%s: %s\n",(char *)data,(char *)tag);
}

void imprimeTags(void * key, void * data, void * d) {
	printf("(%s) - %d\n",(char*)key,*(int*)data);
}

void testPrint() {
	//g_slist_foreach(tags,imprime,"Tag");
	//g_slist_foreach(categories,imprime,"Category");
	//g_hash_table_foreach(tagCount,imprimeTags,NULL);
	printf("Title: %s\n",title);
	printf("Id: %s\n",idPost);
	printf("Date: %s\n",date);
	printf("Text: %s\n",text);
}

%}

%x PUB TAG ID CATEG TITLE DATE TEXT
dig [0-9]


%%
\<pub\>			{ BEGIN PUB; }

<PUB>\</pub\>	{ BEGIN INITIAL; }
<PUB>#TAG: 		{ tags = NULL;BEGIN TAG; }
<PUB>#DATE:" "\[[^\]]+\]" " { BEGIN DATE; }
<PUB>.|\n		{;}

<TAG>#ID:		{ BEGIN ID; }
<TAG>tag:\{[^}]+\}	{
	yytext[yyleng-1]=0;
	char* tag_name = strdup(yytext+5);
	int * count = g_hash_table_lookup(tagCount,tag_name);
	if (count) { // if already exists, increase count
		*count = *count+1;
	}
	else { // else create new entry in hash count
		count = (int *) malloc(sizeof(int));
		*count = 1;
		g_hash_table_insert(tagCount,tag_name,count);
	}
	tags = g_slist_prepend(tags,tag_name);
}
<TAG>.|\n 		{;}

<ID>\}\n		{ categories = NULL; BEGIN CATEG; }
<ID>\{post-{dig}+	{idPost=strdup(yytext+1); }
<ID>.				{;}

<CATEG>\n\n		{ BEGIN TITLE; }
<CATEG>[A-Z][a-z]+	{
	char * category = strdup(yytext);
	categories = g_slist_prepend(categories,category);
}
<CATEG>.|\n 	{;}

<TITLE>\n		{BEGIN PUB;}
<TITLE>[^\n]+	{title = strdup(yytext);}

<DATE>\[.*\]\n		{
	if (text) {
		free(text);
	}
	text = malloc(sizeof(char)*1024);
	textSize = 1024;
	BEGIN TEXT;
}
<DATE>.+		{date = strdup(yytext);}

<TEXT>\nPartilhe" "este" "Artigo\n { formatPrint();BEGIN PUB;}
<TEXT>\nEtiquetas: 				   { formatPrint();BEGIN PUB;}
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

void printBetweenTag(void * tag, void * data) {
	printf("<%s>%s</%s> ",(char *) data, (char *) tag, (char *) data);
}

void printFileBetweenTag(void * tag, void * data) {
	fprintf((FILE *) data, "<li>%s</li>\n",(char * )tag);
}

void htmlInit(FILE * f) {
	fprintf(f,"<html><head><meta charset='UTF-8'/> </head><body>");
}

void formatPrint() {
	printf("<pub id=\"%s\">\n",idPost);
	printf("\t<title>%s</title>\n",title);
	printf("\t<author_date>%s</author_date>\n",date);
	printf("\t<tags>\n\t\t");
	g_slist_foreach(tags,printBetweenTag,"tag");
	printf("\n\t</tags>\n");
	printf("\t<categories>\n\t\t");
	g_slist_foreach(categories,printBetweenTag,"category");
	printf("\n\t</categories>\n");
	printf("\t<text>\n");
	printf("%s\n",text);
	printf("\t</text>\n");
	printf("</pub>\n");
	// now we create the file with html
	char * fileName = malloc(sizeof(char)*512);
	sprintf(fileName,"%s.html",idPost);
	FILE * postHtml = fopen(fileName,"w");
	htmlInit(postHtml);
	fprintf(postHtml,"<h1>%s</h1>\n",idPost+ 5);
	fprintf(postHtml,"<h2>%s</h2>\n",title);
	fprintf(postHtml,"<b>Date: </b>%s\n",date);
	fprintf(postHtml,"<p></p><b>Tags:</b><ul>\n");
	g_slist_foreach(tags,printFileBetweenTag,postHtml);
	fprintf(postHtml,"</ul>\n");

	fclose(postHtml);
}

int main(int argc, char * argv[]) {
	FILE * tagsIndexFile = fopen("tags.html","w");
	tagCount = g_hash_table_new(g_str_hash,g_str_equal);
	yylex();
	return 0;
}
