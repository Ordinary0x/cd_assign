%{
#include <stdio.h>

/* Function provided by the lexer */
int yylex(void);

/* Function used by Bison for syntax errors */
void yyerror(const char *s);
%}


/* TOKENS */

%token BcsMain
%token IF
%token ELSE
%token WHILE
%token INT
%token BOOL
%token id
%token num
%token relop


/* GRAMMAR */

%%
program
    : BcsMain '{' declist stmtlist '}'
    ;


declist
    : declist decl
    | decl
    ;


decl
    : type id ';'
    ;


type
    : INT
    | BOOL
    ;


stmtlist
    : stmtlist ';' stmt
    | stmt
    ;


stmt
    : id '=' aexpr
    | IF '(' expr ')' '{' stmtlist '}' ELSE '{' stmtlist '}'
    | WHILE '(' expr ')' '{' stmtlist '}'
    ;


expr
    : aexpr relop aexpr
    | aexpr
    ;


aexpr
    : aexpr '+' term
    | term
    ;


term
    : term '*' factor
    | factor
    ;


factor
    : id
    | num
    ;

%%


/* ERROR HANDLING */

void yyerror(const char *s)
{
    printf("Syntax Error\n");
}


int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Please provide input file\n");
        return 1;
    }

    /* Redirect stdin to the input program */
    FILE *fp = fopen(argv[1], "r");

    if (fp == NULL)
    {
        printf("Cannot open input file\n");
        return 1;
    }

    extern FILE *yyin;
    yyin = fp;

    if (yyparse() == 0)
    {
        printf("Parsing Successful\n");
    }

    fclose(fp);

    return 0;
}