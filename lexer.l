%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

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

[a-zA-Z][a-zA-Z0-9]*        { return id; }
[0-9]+                      { return num; }

.                           { return yytext[0]; }

%%

int yywrap(void) {
    return 1;
}