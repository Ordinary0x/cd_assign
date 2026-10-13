%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

#define MAXSYM 256
static struct { char *name; int type; } symtab[MAXSYM];
static int nsym = 0;
static int sem_errors = 0;

static int lookup(const char *name)
{
    for (int i = 0; i < nsym; i++)
        if (strcmp(symtab[i].name, name) == 0) return i;
    return -1;
}

static void install(const char *name, int type)
{
    if (lookup(name) >= 0) { 
        fprintf(stderr, "Semantic Error: '%s' declared twice\n", name);
        sem_errors++; 
    }
    else if (nsym < MAXSYM) { 
        symtab[nsym].name = strdup(name); 
        symtab[nsym].type = type;
        nsym++; 
    }
}

static FILE *out;
static int tempcount = 0;
static int in_cond = 0;

static char *newtemp(void)
{
    char buf[32];
    if (in_cond) return strdup("_");
    sprintf(buf, "t%d", ++tempcount);
    return strdup(buf);
}

static void gen(const char *lhs, const char *a, const char *op, const char *b)
{
    if (in_cond) return;
    if (op) fprintf(out, "%s = %s %s %s\n", lhs, a, op, b);
    else    fprintf(out, "%s = %s\n", lhs, a);
}

static void check_declared(const char *name)
{
    if (lookup(name) < 0) {
        fprintf(stderr, "Semantic Error: '%s' used before declaration\n", name);
        sem_errors++;
    }
}
%}

%union { char *s; int t; }

%token BcsMain IF ELSE WHILE INT BOOL relop
%token <s> id num
%type  <s> aexpr term factor
%type  <t> type

%%
program
    : BcsMain '{' declist stmtlist '}'
    ;

declist
    : declist decl
    | decl
    ;

decl
    : type id ';'      { install($2, $1); }
    ;

type
    : INT              { $$ = 0; }
    | BOOL             { $$ = 1; }
    ;

stmtlist
    : stmtlist ';' stmt
    | stmt
    ;

stmt
    : id '=' aexpr     { check_declared($1); gen($1, $3, NULL, NULL); }
    | IF '(' { in_cond++; } expr { in_cond--; } ')' '{' stmtlist '}' ELSE '{' stmtlist '}'
    | WHILE '(' { in_cond++; } expr { in_cond--; } ')' '{' stmtlist '}'
    ;

expr
    : aexpr relop aexpr
    | aexpr
    ;

aexpr
    : aexpr '+' term   { $$ = newtemp(); gen($$, $1, "+", $3); }
    | term             { $$ = $1; }
    ;

term
    : term '*' factor  { $$ = newtemp(); gen($$, $1, "*", $3); }
    | factor           { $$ = $1; }
    ;

factor
    : id               { check_declared($1); $$ = $1; }
    | num              { $$ = $1; }
    ;

%%

void yyerror(const char *s)
{
    printf("Syntax Error\n");
}

int main(int argc, char *argv[])
{
    if (argc < 2) { printf("Usage: %s <input> [output]\n", argv[0]); return 1; }

    FILE *fp = fopen(argv[1], "r");
    if (!fp) { printf("Cannot open input file\n"); return 1; }

    const char *outname = (argc > 2) ? argv[2] : "output.txt";
    out = fopen(outname, "w");
    if (!out) { printf("Cannot open output file\n"); return 1; }

    extern FILE *yyin;
    yyin = fp;

    int rc = yyparse();
    fclose(fp);
    fclose(out);

    if (rc == 0 && sem_errors == 0)
        printf("Parsing Successful. 3-address code written to %s\n", outname);
    else
        remove(outname);
    return 0;
}
