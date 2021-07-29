%{
	#include "common.h"
	#include "lex.yy.c"

	extern "C" int yylex();
	extern "C" void yyerror(const char*);
%}

%union {int iValue; std::vector<int>* vectorIntPtr;};
%token <iValue> TITLE
%token <iValue> CHAPTERNAME
%token <iValue> SECTIONNAME
%token <iValue> PARAGRAPH
%type <vectorIntPtr> paragraphs
%type <vectorIntPtr> sections
%type <vectorIntPtr> chapters
%type <iValue> paragraph
%type <iValue> section
%type <iValue> chapter

%start s
%%
s : TITLE chapters ;

chapters : chapters chapter 
						{
							$1->push_back($2);
							$$ = $1;
						}
	     | chapter 
	     				{
	     					std::vector<int>* tmp = new std::vector<int>;
         					tmp->push_back($1);
         					$$ = tmp;
	     				}
	     ;

chapter : CHAPTERNAME paragraphs sections 
						{
							paragraphs_in_chapter[$1] = $2;
							sections_in_chapter[$1] = $3;
							$$ = $1;
						}
		| CHAPTERNAME paragraphs 
						{
							paragraphs_in_chapter[$1] = $2;
							$$ = $1;
						}
		| CHAPTERNAME sections 
						{
							sections_in_chapter[$1] = $2;
							$$ = $1;
						}
		;

sections : sections section 
						{
							$1->push_back($2);
							$$ = $1;
						}
         | section
         				{
         					std::vector<int>* tmp = new std::vector<int>;
         					tmp->push_back($1);
         					$$ = tmp;
         				}
         ;

section : SECTIONNAME paragraphs 
						{
							paragraphs_in_section[$1] = $2;
							$$ = $1;
						}
        ;

paragraphs : paragraphs paragraph 
						{
							$1->push_back($2);
							$$ = $1;
						}
           | paragraph 
           				{
           					std::vector<int>* tmp = new std::vector<int>;
           					tmp->push_back($1);
           					$$ = tmp;
           				}
           ;

paragraph : PARAGRAPH
						{
							//printf("%s\n\n", paragraphs[$1].c_str());
           					$$ = $1;
           				}
          ;
%%
int main() {
	yyparse();
	// print the title of the dissertation
	fprintf(stdout, "%s\n", title.c_str());
	// print total number of chapters, sections, paragraphs, sentences, words
	fprintf(stdout, "Number of Chapters: %d\n", chapternames.size());
	fprintf(stdout, "Number of Sections: %d\n", sectionnames.size());
	fprintf(stdout, "Number of Paragraphs: %d\n", paragraphs.size());
	fprintf(stdout, "Number of Sentences: %d\n", dsn+esn+isn);
	fprintf(stdout, "Number of Words: %d\n", wn);
	// print the number of declarative, exclamatory and interrogative sentences
	fprintf(stdout, "Number of Declarative Sentences: %d\n", dsn);
	fprintf(stdout, "Number of Exclamatory Sentences: %d\n", esn);
	fprintf(stdout, "Number of Interrogative Sentences: %d\n", isn);
	// pretty print a table of contents
	fprintf(stdout, "Table of Contents:\n");
	for(int i = 0; i < chapternames.size(); i++) {
		fprintf(stdout, "%s\n", chapternames[i].c_str());
		if (sections_in_chapter.find(i) != sections_in_chapter.end()) {
			for(int j : *sections_in_chapter[i]) {
				fprintf(stdout, "\t%s\n", sectionnames[j].c_str());
			}
		}
	}
	return 0;
}

void yyerror (char *s) {
	//fprintf (stderr, "%s\n", s);
	fprintf(stderr, "Error in Parser: The language is not recognized by this grammar!\n");
	exit(0);
}

