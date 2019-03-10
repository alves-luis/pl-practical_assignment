%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <gmodule.h>
GSList * tags;
GSList * categories;
char * idPost;
char * title;
char * date;
char * text;
void imprime(void * tag, void * data){
	printf("%s: %s\n",(char *)data,(char *)tag);
}
%}

%x PUB
%x TAG
%x ID
%x CATEG
%x TITLE
%x DATE
%x TEXT
dig [0-9]


%%
\<pub\>							{BEGIN PUB;}
<PUB>\</pub\>				{BEGIN INITIAL;}
<PUB>#TAG: 					{BEGIN TAG;}
<PUB>#DATE:" "\[[^\]]+\]" " {BEGIN DATE;}
<PUB>.|\n						{;}
<TAG>#ID:						{BEGIN ID;}
<TAG>tag:\{[^}]+\}	{
											yytext[yyleng-1]=0;
	 									 	char* tag_name = strdup(yytext+5);
										 	tags = g_slist_prepend(tags,tag_name);
									 	 }
<TAG>.|\n 					{;}
<ID>\}\n					 	{BEGIN CATEG;}
<ID>\{post-{dig}+		{idPost=strdup(yytext+1);}
<ID>.								{;}
<CATEG>\n\n					{BEGIN TITLE;}
<CATEG>[A-Z][a-z]+	{
											char * category = strdup(yytext);
											categories = g_slist_prepend(categories,category);
										}
<CATEG>.|\n 				{;}
<TITLE>\n						{BEGIN PUB;}
<TITLE>[^\n]+				{title = strdup(yytext);}
<DATE>\n						{text = malloc(sizeof(char)*2); text[1] = '\0'; BEGIN TEXT;}
<DATE>.+						{date = strdup(yytext);}
<TEXT>\nPartilhe" "este" "Artigo\n {BEGIN PUB;}
<TEXT>\nEtiquetas: 								 {BEGIN PUB;}
<TEXT>.*|\n						{int size = strlen(text)+yyleng+1;
											 char * newText = malloc(sizeof(char)*size);
											 strcat(newText,text);
										 	 strcat(newText,yytext);
										 	 text = newText;}
.|\n 						 		{;}
%%

int yywrap() {
	return 1;
}

void testPrint() {
	g_slist_foreach(tags,imprime,"Tag");
	g_slist_foreach(categories,imprime,"Category");
	printf("Title: %s\n",title);
	printf("Id: %s\n",idPost);
	printf("Date: %s\n",date);
	printf("Text: %s\n",text);
}

void printTags(void * tag, void * data) {
	printf("<tag>%s</tag> ",(char *) tag);
}

int main() {
	yylex();
	printf("<pub id=\"%s\">\n",idPost);
	printf("\t<title>%s</title>\n",title);
	printf("\t<author_date>%s</author_date>\n",date);
	printf("\t<tags>\n\t\t");
	g_slist_foreach(tags,printTags,NULL);
	printf("\n\t</tags>\n");
	// printf("<category>") don't know what to do here :(
	printf("\t<text>\n");
	printf("%s\n",text);
	printf("\t</text>\n");
	printf("</pub>\n");
	return 0;
}
