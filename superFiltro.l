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

void freeString(void * string) {
	free((char *)string);
}

%}

%x PUB TAG ID CATEG TITLE DATE TEXT
dig [0-9]


%%
\<pub\>											{ BEGIN PUB; }

<PUB>\</pub\>								{ BEGIN INITIAL; }
<PUB>#TAG: 									{
	if (tags)
		g_slist_free(tags);
	BEGIN TAG;
}
<PUB>#DATE:" "\[[^\]]+\]" " {
	if(date)
		free(date);
	BEGIN DATE;
														}
<PUB>.|\n										{;}

<TAG>#ID:						{
	if (idPost)
		free(idPost);
	BEGIN ID;
										}
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
<TAG>.|\n 					{;}

<ID>\}\n					 	{
	if (categories)
		g_slist_free(categories);
	BEGIN CATEG;
										}
<ID>\{post-{dig}+		{idPost=strdup(yytext+1); }
<ID>.								{;}

<CATEG>\n\n					{
	if (title)
		free(title);
	BEGIN TITLE;
										}
<CATEG>[A-Z][a-z]+	{
	char * category = strdup(yytext);
	categories = g_slist_prepend(categories,category);
										}
<CATEG>.|\n 				{;}

<TITLE>\n						{BEGIN PUB;}
<TITLE>[^\n]+				{title = strdup(yytext);}

<DATE>\n						{
	if (text)
		free(text);
	text = malloc(sizeof(char)*2);
	text[1] = '\0';
	BEGIN TEXT;
										}
<DATE>.+						{date = strdup(yytext);}

<TEXT>\nPartilhe" "este" "Artigo\n {BEGIN PUB;}
<TEXT>\nEtiquetas: 								 {BEGIN PUB;}
<TEXT>.*|\n												 {
	int size = strlen(text)+yyleng+1;
	char * newText = malloc(sizeof(char)*size);
	strcpy(newText,text);
	strcat(newText,yytext);
	free(text);
	text = newText;
																	 }
.|\n 						 					 				 {;}
%%

int yywrap() {
	return 1;
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
	g_hash_table_foreach(tagCount,imprimeTags,NULL);
	/*printf("Title: %s\n",title);
	printf("Id: %s\n",idPost);
	printf("Date: %s\n",date);
	printf("Text: %s\n",text);*/
}

void printTags(void * tag, void * data) {
	printf("<tag>%s</tag> ",(char *) tag);
}

void htmlInit(FILE * f) {
	fprintf(f,"<html><head><meta charset='UTF-8'/> </head><body>");
}

int main(int argc, char * argv[]) {
	FILE * tagsIndexFile = fopen("tags.html","w");
	tagCount = g_hash_table_new(g_str_hash,g_str_equal);
	yylex();
	testPrint();
	/*printf("<pub id=\"%s\">\n",idPost);
	printf("\t<title>%s</title>\n",title);
	printf("\t<author_date>%s</author_date>\n",date);
	printf("\t<tags>\n\t\t");
	g_slist_foreach(tags,printTags,NULL);
	printf("\n\t</tags>\n");
	// printf("<category>") don't know what to do here :(
	printf("\t<text>\n");
	printf("%s\n",text);
	printf("\t</text>\n");
	printf("</pub>\n");*/
	return 0;
}
