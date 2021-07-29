%{	
	#include "common.h"
	#include "y.tab.h"
	extern "C" int yylex();

	bool reading_paragraph = false;
	std::string paragraph_being_read = "";
	char tmp[] = "stdin";
	char* yyfilename = tmp;

	void invokeErrorAndExit(const char* token){
		error_flag = true;
		fprintf(stderr, "%s !\n", token);
		exit(0);
	}
%}
%Start word separator
%%
([Tt]itle|TITLE).*$	{
				// this is the title of the thesis
				title = std::string(yytext);
				yylval.iValue = 0;
				return (TITLE);
			}
([Cc]hapter|CHAPTER).*$ {
				//this is a chapter inside the thesis
				chapternames.push_back(std::string(yytext));
				yylval.iValue = chapternames.size() - 1;
				// yylval is the value returned (chapter index starting from 0) when this is recognized
				BEGIN word;
				return (CHAPTERNAME);
			}
([Ss]ection|SECTION).*$	{
				// this is a section inside a chapter
				sectionnames.push_back(std::string(yytext));
				yylval.iValue = sectionnames.size() - 1;
				// yylval is the value returned (section index starting from 0) when this is recognized
				BEGIN word;
				return (SECTIONNAME);
			}

<word>([+-]?[0-9]*)|([+-]?[0-9]*.[0-9]+)|([+-]?[0-9]+.[0-9]) {
				// an integer or a decimal number, will not be counted as a word
				yymore();
				BEGIN separator;
			}

<word>[a-zA-Z0-9]+ 	{
				// a word in a sentence
				nwords_in_sentence++;
				yymore();
				BEGIN separator;
			}

<separator>[\.\!\?]	{
				// sentence ends here
				switch(yytext[yyleng-1]) {
					case '.' : dsn++; break;
					case '!' : esn++; break;
					case '?' : isn++; break;
				}
				wn += nwords_in_sentence;
				nwords_in_sentence = 0;
				// a paragraph should have one or more lines
				reading_paragraph = true;
				// append this sentence to the current paragraph
				paragraph_being_read += std::string(yytext);
				BEGIN word;		
			}

<separator>[,;]		{
				// word separator which cannot repeat
				BEGIN word;
			}

[ \t]+		{
				// word separator which can occur multiple times
				yymore();
				BEGIN word;
			}

[\n\r]+		{
				if (reading_paragraph) {
					// paragraph ends here
					if (nwords_in_sentence > 0) {
						invokeErrorAndExit((std::string("Error in Lexer: Incomplete sentence ") + std::string(yytext)).c_str());
						nwords_in_sentence = 0;
					}
					if (yyleng == 1) {
						BEGIN 0;
					} else {
						BEGIN word;
						// can start reading another paragraph
					}
					paragraphs.push_back(paragraph_being_read);
					paragraph_being_read.clear();
					reading_paragraph = false;
					yylval.iValue = paragraphs.size() - 1;
					return (PARAGRAPH);
				}
			}

<<EOF>>		{
				if (reading_paragraph) {
					// paragraph ends here
					if (nwords_in_sentence > 0) {
						invokeErrorAndExit((std::string("Error in Lexer: Incomplete sentence ") + std::string(yytext)).c_str());
						nwords_in_sentence = 0;
					}
					if (yyleng == 1) {
						BEGIN 0;
					} else {
						BEGIN word;
						// can start reading another paragraph
					}
					paragraphs.push_back(paragraph_being_read);
					paragraph_being_read.clear();
					reading_paragraph = false;
					yylval.iValue = paragraphs.size() - 1;
					return (PARAGRAPH);
				}
				yyterminate();
			}
.			{
				// error
				invokeErrorAndExit((std::string("Error in Lexer: Illegal Token, ") + std::string(yytext)).c_str());
			}		
%%
int yywrap() {
	// when EOF is reached first yywrap() is called 
	// if it returns 1 then the action for regex <<EOF>>
	// if it returns 0 then the whote text is read again
	return 1;
}