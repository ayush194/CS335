	#include <unordered_map>
	#include <iostream>
	#include <iomanip>
	#include <string>

	extern "C" int yylex();
	std::unordered_map<std::string, std::pair<std::string, int>> lexemes;
	void insert_lexeme(const std::string& lex, const std::string& lex_class) {
		if (lexemes.find(lex) == lexemes.end()) {
			//new lexeme found
			lexemes[lex] = make_pair(lex_class, 1);
		} else {
			//identifier has already been found
			lexemes[lex].second++;
		}
	}

	bool error = false;
	char tmp[] = "stdin";
	char* yyfilename = tmp;
	int main(int argc, char* argv[]) {
		FILE *fh1, *fh2;

		if (argc >= 2) {
			fh1 = fopen(argv[1], "r");
			yyin = fh1;
			yyfilename = argv[1];
		}
		if (argc >= 3) {
			fh2 = fopen(argv[2], "w");
			yyout = fh2;
		}
		yylex();
		return 0;
	}

alphan	[0-9A-Za-z_$]
floattypesuffix [fFdD]
integertypesuffix [Ll]

alphadigit	[0-9A-Za-z]
alphadigitorunderscore {alphadigit}|_
alphadigitandunderscores {alphadigitorunderscore}+
alphadigits {alphadigit}|({alphadigit}{alphadigitandunderscores}?{alphadigit})

alphadigit_	[0-9AC-WYZac-wyz]
alphadigitorunderscore_ {alphadigit_}|_
alphadigitandunderscores_ {alphadigitorunderscore_}+
alphadigits_ {alphadigit_}|({alphadigit_}{alphadigitandunderscores_}?{alphadigit_})

nonzerodigit [1-9]
digit 0|{nonzerodigit}
digitorunderscore {digit}|_
digitandunderscores {digitorunderscore}+
digits	{digit}|({digit}{digitandunderscores}?{digit})
decimalnumeral 0|({nonzerodigit}{digits}?)|({nonzerodigit}_*{digits})
decimalintegerliteral {decimalnumeral}{integertypesuffix}?
decimalnumeralerr ({nonzerodigit}{alphadigits}?)|({nonzerodigit}_*{alphadigits})
decimalintegerliteralerr {decimalnumeralerr}{integertypesuffix}?

hexdigit [0-9a-fA-F]
hexdigitorunderscore {hexdigit}|_
hexdigitandunderscores {hexdigitorunderscore}+
hexdigits {hexdigit}|({hexdigit}{hexdigitandunderscores}?{hexdigit})
hexnumeral 0[xX]{hexdigits}
hexintegerliteral {hexnumeral}{integertypesuffix}?
hexnumeralerr 0[xX]{alphadigits}
hexintegerliteralerr {hexnumeralerr}{integertypesuffix}?

octaldigit [0-7]
octaldigitorunderscore {octaldigit}|_
octaldigitandunderscores {octaldigitorunderscore}{octaldigitorunderscore}*
octaldigits {octaldigit}|({octaldigit}{octaldigitandunderscores}?{octaldigit})
octalnumeral (0{octaldigits})|(0_*{octaldigits})
octalintegerliteral {octalnumeral}{integertypesuffix}?
octalnumeralerr (0{alphadigits})|(0_*{alphadigits})
octalintegerliteralerr {octalnumeralerr}{integertypesuffix}?

binarydigit [0-1]
binarydigitorunderscore {binarydigit}|_
binarydigitandunderscores {binarydigitorunderscore}+
binarydigits {binarydigit}|({binarydigit}{binarydigitandunderscores}?{binarydigit})
binarynumeral 0[bB]{binarydigits}
binaryintegerliteral {binarynumeral}{integertypesuffix}?
binarynumeralerr 0[bB]{alphadigits}
binaryintegerliteralerr {binarynumeralerr}{integertypesuffix}?

signedinteger [+\-]?{digits}
exponentpart [eE]{signedinteger}
decimalfloatingpointliteral ({digits}\.{digits}?{exponentpart}?{floattypesuffix}?)|(\.{digits}{exponentpart}?{floattypesuffix}?)|({digits}{exponentpart}{floattypesuffix}?)|({digits}{exponentpart}?{floattypesuffix})
decimalfloatingpointliteralerr ({digits}\.{alphadigits}?{exponentpart}?{floattypesuffix}?)|(\.{digit}_*{alphadigits}{exponentpart}?{floattypesuffix}?)|({nonzerodigit}_*{alphadigits}{exponentpart}{floattypesuffix}?)|({nonzerodigit}_*{alphadigits}{exponentpart}?{floattypesuffix})

hexsignificand ({hexnumeral}\.?)|(0[xX]{hexdigits}?\.{hexdigits})
binaryexponent [pP]{signedinteger}
hexdecimalfloatingpointliteral {hexsignificand}{binaryexponent}{floattypesuffix}?
hexsignificanderr ({hexnumeralerr}\.?)|(0[xX]{alphadigits}?\.{alphadigits})
hexdecimalfloatingpointliteralerr {hexsignificanderr}{binaryexponent}{floattypesuffix}?

octalescape	(\\[0-7])|(\\[0-7][0-7])|(\\[0-3][0-7][0-7])
octalescapeerr (\\[0-9])|(\\[0-9][0-9])|(\\[0-9][0-9][0-9])
escapeseq	(\\[btfnr'"\\])|({octalescape})
escapeseqerr (\\.)|{octalescapeerr}
unicodeescape	\\u{hexdigit}{hexdigit}{hexdigit}{hexdigit}
unicodeescapeerr	\\u....
inputchar1	[^'\\\n\r]|{unicodeescape}
inputchar2	[^"\\\n\r]|{unicodeescape}
inputchar1err [^'\\]|{unicodeescape}
inputchar2err [^"\\]|{unicodeescape}
illegalchar [^ \b\t\n\f\r(){}[\];,.@:><!~?\-=&|+*\^%/]
stringchar	{inputchar2}|{escapeseq}
stringcharerr {inputchar2}|{escapeseqerr}
whitespace	[ \b\t\n\f\r]
nonwhitespace	[^ \b\t\n\f\r]

%Start commented
%%

\/\/.*$								{
										//This is a comment. Ignore it
									}

\/\*								{
										//Comment begins
										BEGIN commented;
									}

<commented>[^*]*					{
										//consume everything inside a comment
									}

<commented>\*[^*/]*					{}

<commented>\*\/						{
										//Commend ends
										BEGIN 0;
									}

{whitespace}+						{;}

Float\.NaN 							{
										insert_lexeme(std::string(yytext), "Literal");
									}

Double\.NaN 							{
										insert_lexeme(std::string(yytext), "Literal");
									}

{decimalintegerliteral}					{
										//Integer Literal (Decimal)
										insert_lexeme(std::string(yytext), "Literal");
									}

{hexintegerliteral}					{
										//Integer Literal (Hexadecimal)
										insert_lexeme(std::string(yytext), "Literal");
									}

{octalintegerliteral}				{
										//Integer Literal (Octal)
										insert_lexeme(std::string(yytext), "Literal");
									}

{binaryintegerliteral}				{
										//Integer Literal (Binary)	
										insert_lexeme(std::string(yytext), "Literal");
									}

{decimalfloatingpointliteral}		{
										//Floating Point Literal (Decimal)
										insert_lexeme(std::string(yytext), "Literal");
									}

{hexdecimalfloatingpointliteral}	{
										//Floating Point Literal (Hexadecimal)
										insert_lexeme(std::string(yytext), "Literal");
									}

{decimalintegerliteralerr}			{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Invalid Decimal Literal %s\n", yyfilename, yylineno, yytext);
									}

{hexintegerliteralerr}				{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Invalid Hex Literal %s\n", yyfilename, yylineno, yytext);
									}

{binaryintegerliteralerr}			{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Invalid Binary Literal %s\n", yyfilename, yylineno, yytext);
									}

{octalintegerliteralerr}			{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Invalid Octal Literal %s\n", yyfilename, yylineno, yytext);
									}

{hexdecimalfloatingpointliteralerr}	{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Invalid Hex Floating Point Literal %s\n", yyfilename, yylineno, yytext);
									}									

{decimalfloatingpointliteralerr}	{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Invalid Floating Point Literal %s\n", yyfilename, yylineno, yytext);
									}									

(true|false)[^A-Za-z0-9_$]			{
										//this is a boolean literal
										yyless(yyleng-1);
										insert_lexeme(std::string(yytext), "Literal");
									}

(\'{inputchar1}\')|(\'{escapeseq}\')		{
										//this is a character literal
										insert_lexeme(std::string(yytext), "Literal");
									}

\'{escapeseqerr}\'					{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Escape Sequence error in character literal %s\n", yyfilename, yylineno, yytext);
									}

\'{unicodeescapeerr}\'				{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Unicode Escape error in character literal %s\n", yyfilename, yylineno, yytext);
									}

\'({inputchar1}|{escapeseq}|{escapeseqerr}|{unicodeescapeerr})+\' {
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Character Literal %s too long\n", yyfilename, yylineno, yytext);
									}

(\"{stringchar}*\")					{
										//this is a string literal
										insert_lexeme(std::string(yytext), "Literal");
									}

(\"{stringcharerr}*\")				{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Escape Sequence error in string literal %s\n", yyfilename, yylineno, yytext);
									}

null[^A-Za-z0-9_$]					{
										//this is a null literal
										yyless(yyleng-1);
										insert_lexeme(std::string(yytext), "Literal");
									}

(abstract|continue|for|new|switch|assert|default|if|package|synchronized|boolean|do|goto|private|this|break|double|implements|protected|throw|byte|else|import|public|throws|case|enum|instanceof|return|transient|catch|extends|int|short|try|char|final|interface|static|void|class|finally|long|strictfp|volatile|const|float|native|super|while)[^A-Za-z0-9_$]		{
										//this is a reserved keyword
										//a reserved keyword cannot be followed by something that makes it an identifier
										//can be followed by space,[],(),<>,
										yyless(yyleng-1);
										insert_lexeme(std::string(yytext), "Keyword");
									}

[A-Za-z_$][A-Za-z_$0-9]* 			{
										//this is an identifier
										insert_lexeme(std::string(yytext), "Identifier");
									}

([A-Za-z_$]{illegalchar})*			{
										error = true;
										//invalid characters in identifier
										fprintf(stderr, "%s: %d: Lexical Error: Illegal characters in Identifier %s\n", yyfilename, yylineno, yytext);
									}									



\(|\)|\{|\}|\[|\]|\;|\,|\.|(\.\.\.)|\@|(\:\:) {
										//this is a separator
										insert_lexeme(std::string(yytext), "Separator");
									}

(=|\>|\<|!|~|\?|:|(-\>)|(==)|(\>=)|(\<=)|(!=)|(&&)|(\|\|)|(\+\+)|(\-\-)|\+|\-|\*|\/|&|\||\^|\%|(\<\<)|(\>\>)|(\>\>\>)|(\+=)|(\-=)|(\*=)|(\/=)|(&=)|(\|=)|(\^=)|(\%=)|(\<\<=)|(\>\>=)|(\>\>\>=)) {
										//this is an operator
										insert_lexeme(std::string(yytext), "Operator");
									}

.									{
										error = true;
										fprintf(stderr, "%s: %d: Lexical Error: Illegal character %s\n", yyfilename, yylineno, yytext);
									}


%%
int yywrap() {
	if (error) return 1;
	//std::cout << "-----------------\n";
	//int width = 20;
	//std::cout << "+";
	//for(int i = 0; i < 3*width+2; i++) std::cout << "-";
	//std::cout << "+\n";
	//std::cout << "|" << std::setw(width) << "Lexeme" << 
	//			 "|" << std::setw(width) << "Token" << 
	//			 "|" << std::setw(width) << "Count" << "|\n";
	fprintf(yyout, "Lexeme,Token,Count\n");
	//std::cout << "|";
	//for(int i = 0; i < 3*width+2; i++) std::cout << "-";
	//std::cout << "|\n";
	for(auto it = lexemes.begin(); it != lexemes.end(); it++) {
		//std::cout << it->first << ' ' << it->second.first << ' ' << it->second.second << std::endl;
		fprintf(yyout, "%s,%s,%d\n", it->first.c_str(), it->second.first.c_str(), it->second.second);
		//std::cout << "|" << std::setw(width) << it->first << 
		//			 "|" << std::setw(width) << it->second.first << 
		//			 "|" << std::setw(width) << it->second.second << "|" << std::endl;
	}
	//std::cout << "+";
	//for(int i = 0; i < 3*width+2; i++) std::cout << "-";
	//std::cout << "+\n";
	return 1;
}