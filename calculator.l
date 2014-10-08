typedef enum { typeCon, typeId, typeOpr } nodeEnum;

/* constants */
typedef struct {
    int value;    /* value of constant */
} conNodeType;

/* identifiers */
typedef struct {
    int i;        /* subscript to sym array */
} idNodeType;

/* operators */
typedef struct {
    int oper;     /* operator */
    int nops;     /* number of operands */
    struct nodeTypeTag **op; /* operands */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;     /* type of node */
    union {
        conNodeType con;  /* constants */
        idNodeType id;    /* identifiers */
        oprNodeType opr;  /* operators */
    };
} nodeType;

extern int sym[26];

%{
#include <stdlib.h>
#include "calc3.h"
#include "y.tab.h"
void yyerror(char *);
%}

%%

[a-z] {
        yylval.sIndex = *yytext - 'a';
        return VARIABLE;
      }

0     {
        yylval.iValue = atoi(yytext);
        return INTEGER;
      }

[1-9][0-9]* {
              yylval.iValue = atoi(yytext);
              return INTEGER;
            }
    


[-()<>=+*/;{}.] {
                return *yytext;
              }

">="          return GE;
"<="          return LE;
"=="          return EQ;
"!="          return NE;
"while"       return WHILE;
"if"          return IF;
"else"        return ELSE;
"print"       return PRINT;

[ \t\n]+ ;       /* ignore whitespace */

.             yyerror("Unknown character");
%%
int yywrap(void) {
  return 1; 
}