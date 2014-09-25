%{ 
  #include <stdio.h>
  /* this seems to be superflous, but does get rid of a compiler warning, this function comes with the flex library */
  int yylex(void); 
  void yyerror(char *); 
%}

%token INTEGER 
%token ADD

%% 

program: 
        expr '\n' { printf("%d\n", $1); } 
        | 
        ; 
expr: 
        INTEGER { $$ = $1; } 
        | expr ADD expr { $$ = $1 + $3; } 
        | expr '-' expr { $$ = $1 - $3; } 
        ;

%%

void yyerror(char *s) { 
  fprintf(stderr, "%s\n", s); 
} 

int main(void) { 
  yyparse(); 
  return 0; 
}