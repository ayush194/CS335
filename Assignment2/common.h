#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
#include <map>

bool error_flag = false;
int nwords_in_sentence = 0;
int wn = 0, dsn = 0, esn = 0, isn = 0;
std::string title;
std::vector<std::string> chapternames, sectionnames, paragraphs;
// sections_in_chapter[i] gives all sections inside chapter i
std::map<int, std::vector<int>*> sections_in_chapter;
// paragraphs_in_section[i] gives all paragraphs inside section i
std::map<int, std::vector<int>*> paragraphs_in_section;
// paragraphs_in_chapter[i] is a paragraph which doesn't belong in any section
std::map<int, std::vector<int>*> paragraphs_in_chapter;

#endif
