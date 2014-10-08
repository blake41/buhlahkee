%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "calc3.h"

/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);

void yyerror(char *s);
int sym[26];          /* symbol table */
%}

%union {
    int iValue;       /* integer value */

    char sIndex;      /* symbol table index */

    nodeType *nPtr;   /* node pointer */
};

%token <iValue> INTEGER
%token <sIndex> VARIABLE
%token WHILE IF PRINT
%nonassoc IFX
%nonassoc ELSE

%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <nPtr> stmt expr stmt_list

%%
program:
  function        { exit(0); }
  ;

function:
    function stmt  { ex($2); freeNode($2); }
| /* NULL */ 
;

stmt: 
    ';'                      {$$= opr(';', 2, NULL, NULL); } 
  | expr ';'                 {$$= $1; }

  | PRINT expr ';'           {$$= opr(PRINT, 1, $2); }
  | VARIABLE '=' expr ';'    {$$= opr('=', 2, id($1), $3); }
  | WHILE '(' expr ')' stmt  { $$ = opr(WHILE, 2, $3, $5); }
  | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
  | IF '(' expr ')' stmt ELSE stmt
                             { $$ = opr(IF, 3, $3, $5, $7); }
  | '{' stmt_list '}'        {$$= $2; }
    ;

stmt_list:
    stmt                     { $$=$1;}
  | stmt_list stmt           { $$ = opr(';', 2, $1, $2); }
  ;

expr:
    INTEGER               { $$ = con($1); }
  | VARIABLE              { $$ = id($1); }
  | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
  | expr '+' expr         { $$ = opr('+', 2, $1, $3); }
  | expr '-' expr         { $$ = opr('-', 2, $1, $3); }
  | expr '*' expr         { $$ = opr('*', 2, $1, $3); }
  | expr '/' expr         { $$ = opr('/', 2, $1, $3); }
  | expr '<' expr         { $$ = opr('<', 2, $1, $3); }
  | expr '>' expr         { $$ = opr('>', 2, $1, $3); }
  | expr GE expr          { $$ = opr(GE, 2, $1, $3); }
  | expr LE expr          { $$ = opr(LE, 2, $1, $3); }
  | expr NE expr          { $$ = opr(NE, 2, $1, $3); }
  | expr EQ expr          { $$ = opr(EQ, 2, $1, $3); }
  | '(' expr ')'          { $$=$2;}
  ;

%%
#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)

nodeType *con(int value) {
  nodeType *p;
  /* allocate node */
  if ((p = malloc(sizeof(nodeType))) == NULL)
      yyerror("out of memory");
  /* copy information */
  p->type = typeCon;
  p->con.value = value;
  return p; 
}

nodeType *id(int i) {
  nodeType *p;
  /* allocate node */
  if ((p = malloc(sizeof(nodeType))) == NULL)
      yyerror("out of memory");
  /* copy information */
  p->type = typeId;
  p->id.i = i;
  return p; 
}

nodeType *opr(int oper, int nops, ...) {
  va_list ap;
  nodeType *p;
  int i;
  /* allocate node */
  if ((p = malloc(sizeof(nodeType))) == NULL)
      yyerror("out of memory");
  if ((p->opr.op = malloc(nops * sizeof(nodeType))) == NULL)
      yyerror("out of memory");
  /* copy information */
  p->type = typeOpr;
  p->opr.oper = oper;
  p->opr.nops = nops;
  va_start(ap, nops);
  for (i = 0; i < nops; i++)
      p->opr.op[i] = va_arg(ap, nodeType*);
  va_end(ap);
  return p; 
}
void freeNode(nodeType *p) {
  int i;

  if (!p) return;
  if (p->type == typeOpr) {
      for (i = 0; i < p->opr.nops; i++)
          freeNode(p->opr.op[i]);
      free(p->opr.op);
  }
  free (p); 
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
  yyparse();
  return 0; 
}

/* compiler */

#include <stdio.h>
#include "calc3.h"
#include "y.tab.h"

static int lbl;

int ex(nodeType *p) {
  int lbl1, lbl2;

  if (!p) return 0;
  switch(p->type) {
  case typeCon:
      printf("\tpush\t%d\n", p->con.value);
      break;
  case typeId:
      printf("\tpush\t%c\n", p->id.i + 'a');
      break;
  case typeOpr:
      switch(p->opr.oper) {
      case WHILE:
          printf("L%03d:\n", lbl1 = lbl++);
          ex(p->opr.op[0]);
          printf("\tjz\tL%03d\n", lbl2 = lbl++);
          ex(p->opr.op[1]);
          printf("\tjmp\tL%03d\n", lbl1);
          printf("L%03d:\n", lbl2);
          break;
      case IF:
          ex(p->opr.op[0]);
          if (p->opr.nops > 2) {
              /* if else */
              printf("\tjz\tL%03d\n", lbl1 = lbl++);
              ex(p->opr.op[1]);
              printf("\tjmp\tL%03d\n", lbl2 = lbl++);
              printf("L%03d:\n", lbl1);
              ex(p->opr.op[2]);
              printf("L%03d:\n", lbl2);
          } else {
              /* if */
              printf("\tjz\tL%03d\n", lbl1 = lbl++);
              ex(p->opr.op[1]);
              printf("L%03d:\n", lbl1);
          } 
          break;
      
      case PRINT:
          ex(p->opr.op[0]);
          printf("\tprint\n");
          break;

          case '=':
              ex(p->opr.op[1]);
              printf("\tpop\t%c\n", p->opr.op[0]->id.i + 'a');
              break;
          case UMINUS:
              ex(p->opr.op[0]);
              printf("\tneg\n");
              break;
          default:
              ex(p->opr.op[0]);
              ex(p->opr.op[1]);
              switch(p->opr.oper) {
              case '+':  printf("\tadd\n"); break;
              case '-':  printf("\tsub\n"); break;
              case '*':  printf("\tmul\n"); break;
              case '/':  printf("\tdiv\n"); break;
              case '<':  printf("\tcompLT\n"); break;
              case '>':  printf("\tcompGT\n"); break;
              case GE:   printf("\tcompGE\n"); break;
              case LE:   printf("\tcompLE\n"); break;
              case NE:   printf("\tcompNE\n"); break;
              case EQ:   printf("\tcompEQ\n"); break;
              }
      } 
  }
  return 0; 
}
            
            
            
            
            
            
            
            
            
            
      