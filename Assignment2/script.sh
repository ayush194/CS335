if [ $# -gt 0 ]
then
	yacc -d thesisparser.y
	lex thesislexer.l
	g++ -w -std=c++11 -o thesisparser y.tab.c -ly -ll
	./thesisparser < $1
else
	echo "Please specify the textfile!"
	echo "Format: sh script.sh samplethesis.txt"
fi