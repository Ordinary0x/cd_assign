%{
#include "parser_1.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%option noyywrap nounput noinput

%%

[ \t\n\r]+                  { /* Skip whitespace */ }

"BcsMain"                   { return BcsMain; }
"int"                       { return INT; }
"bool"                      { return BOOL; }
"if"                        { return IF; }
"else"                      { return ELSE; }
"while"                     { return WHILE; }

"="                         { return '='; }
"+"                         { return '+'; }
"*"                         { return '*'; }

";"                         { return ';'; }
"{"                         { return '{'; }
"}"                         { return '}'; }
"("                         { return '('; }
")"                         { return ')'; }

"<"|">"|"<="|">="|"=="|"!=" { return relop; }

[a-zA-Z][a-zA-Z0-9]*        { yylval.s = strdup(yytext); return id; }
[0-9]+                      { yylval.s = strdup(yytext); return num; }

.                           { return yytext[0]; }

%%
