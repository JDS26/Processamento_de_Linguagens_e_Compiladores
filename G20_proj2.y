%{
#include <stdlib.h>  /* malloc */
#include <stdio.h>
#include <string.h>
#include "uthash.h"

enum cat {Var, Array, Funct};
enum tipo {Int, Car, Arr};

struct my_struct {
    char name[10];             /* key (string is WITHIN the structure) */
    int end;
    enum cat category;
    enum tipo tipo;
    int dim;
    UT_hash_handle hh;         /* makes this structure hashable */
};


int yylex();
void yyerror(char *s);
char *errArr (char *id, char *expr, int dim, int *count);
float TabId[26];
FILE *exe;
struct my_struct *s, *tmp, *users = NULL;

int cfor = 1;
int cse = 1;
int carr = 1;
int fp = 0;

%}

%union{ int valN; char *valC;char *inst;}
%token <valN>NUM
%token <valC>ID
%token WRITE 
%token FOR DO
%token SE SENAO
%token SC RET
%token TRUE FALSE
%token MOD IG DIF IMA MA IME ME INC DEC

%type <inst> Inics Comms Prints
%type <inst> Atrib Ciclo Opcao 
%type <inst> Iter Conds Expr Termo Fator

%start Codigo

%%

Codigo : Inics Comms RET ';' {fprintf (exe, "%sstart\n%sstop",$1,$2);} 

Inics : Inics ID ';'                    { s = (struct my_struct *)malloc(sizeof *s);
                                            strcpy(s->name, $2);
                                            s->end = fp;
                                            s->category = Var;
                                            s->tipo = Int;
                                            s->dim = 1;
                                            HASH_ADD_STR( users, name, s );
                                            fp++;
                                            asprintf(&$$,"%s\tpushi 0\n",$1);
                                        }
      | Inics ID '[' NUM ']' ';'        { // opção para declarar um array
                                            s = (struct my_struct *)malloc(sizeof *s); 
                                            strcpy(s->name, $2);
                                            s->end = fp;
                                            s->category = Array;
                                            s->tipo = Arr;
                                            s->dim = $4;
                                            fp= fp + s->dim;
                                            HASH_ADD_STR( users, name, s );
                                            asprintf(&$$,"%s\tpushn %d\n",$1,$4);
                                        }
      | ID ';'                          { s = (struct my_struct *)malloc(sizeof *s);
                                            strcpy(s->name, $1);
                                            s->end = fp;
                                            s->category = Var;
                                            s->tipo = Int;
                                            s->dim = 1;
                                            HASH_ADD_STR( users, name, s );
                                            fp++;
                                            asprintf(&$$,"\tpushi 0\n");
                                        }
      | ID '[' NUM ']' ';'              { // opção para declarar um array
                                            s = (struct my_struct *)malloc(sizeof *s); 
                                            strcpy(s->name, $1);
                                            s->end = fp;
                                            s->category = Array;
                                            s->tipo = Arr;
                                            s->dim = $3;
                                            fp= fp + s->dim;
                                            HASH_ADD_STR( users, name, s );
                                            asprintf(&$$,"\tpushn %d\n",$3);
                                        }
      ;

Comms : Comms Atrib ';'               {asprintf(&$$,"%s%s",$1,$2);}
      | Comms Ciclo                   {asprintf(&$$,"%s%s",$1,$2);} 
      | Comms Opcao                   {asprintf(&$$,"%s%s",$1,$2);}
      | Comms Iter ';'                {asprintf(&$$,"%s%s",$1,$2);}
      | Comms RET ';'                 {asprintf(&$$,"%s\tstop\n",$1);}
      | Comms Prints ';'              {asprintf(&$$,"%s%s",$1,$2);}
      | Atrib ';'                     {asprintf(&$$,"%s",$1);} 
      | Ciclo                         {asprintf(&$$,"%s",$1);} 
      | Opcao                         {asprintf(&$$,"%s",$1);}
      | Iter ';'                      {asprintf(&$$,"%s",$1);}
      | Prints ';'                    {asprintf(&$$,"%s",$1);}
      | RET ';'                       {asprintf(&$$,"%s\tstop\n");}
      ;

Prints: WRITE '(' Expr ')'            {asprintf(&$$,"%s\twritei\n",$3);}
      ;     

Ciclo : FOR '{' Atrib ';' Conds ';' Iter '}' DO '{' Comms '}'     { asprintf(&$$,"%siniciofor%d : nop \n%s\tjz fimfor%d\n%s%s\tjump iniciofor%d\nfimfor%d : nop\n", $3, cfor, $5, cfor, $11, $7, cfor, cfor);cfor++; }
      ;

Opcao : SE ':' Conds ':' '{' Comms '}' SENAO '{' Comms '}'               { asprintf(&$$,"%s\tjz iniciosenao%d\n%s\tjump fimsenao%d\niniciosenao%d :  nop \n%sfimsenao%d :  nop \n", $3, cse, $6, cse, cse, $10, cse); cse++; }
      | SE ':' Conds ':' '{' Comms '}'                                   { asprintf(&$$,"%s\tjz iniciosenao%d\n%s iniciosenao%d :  nop\n", $3, cse, $6, cse); cse++; }
      ;

Iter : ID INC                     { HASH_FIND_STR( users, $1, s);
                                      if (s) { 
                                        if ((s->category == Var) && (s->tipo == Int)) { 
                                        asprintf(&$$,"\tpushg %d\n\tpushi 1\n\tadd\n\tstoreg %d\n", s->end, s->end);
                                        } 
                                        else { printf("\n\n   Erro Desconhecido   \n\n"); }
                                      } 
                                      else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                                    }
     | ID DEC                     { HASH_FIND_STR( users, $1, s);
                                     if (s) { 
                                        if ((s->category == Var) && (s->tipo == Int)) { 
                                        asprintf(&$$,"\tpushg %d\n\tpushi 1\n\tsub\n\tstoreg %d\n", s->end, s->end);
                                        } 
                                        else { printf("\n\n   Erro Desconhecido   \n\n"); }
                                      } 
                                      else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                                    }
     | INC ID                      { HASH_FIND_STR( users, $2, s);
                                      if (s) { 
                                        if ((s->category == Var) && (s->tipo == Int)) { 
                                        asprintf(&$$,"\tpushg %d\n\tpushi 1\n\tadd\n\tstoreg %d\n", s->end, s->end);
                                        } 
                                        else { printf("\n\n   Erro Desconhecido   \n\n"); }
                                      } 
                                      else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $2);}
                                    }
     | DEC ID                     { HASH_FIND_STR( users, $2, s);
                                     if (s) { 
                                        if ((s->category == Var) && (s->tipo == Int)) { 
                                        asprintf(&$$,"\tpushg %d\n\tpushi 1\n\tsub\n\tstoreg %d\n", s->end, s->end);
                                        } 
                                        else { printf("\n\n   Erro Desconhecido   \n\n"); }
                                      } 
                                      else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $2);}
                                    }
     ;

Conds : '(' Conds ')' E '(' Conds ')'     { asprintf(&$$, "%s\tdup 1\n\tjz efim%d\n%s\tmul\nefim%d :  nop\n", $2, ce, $6, ce); ce++; }
      | '(' Conds ')' OU '(' Conds ')'    { asprintf(&$$, "%s\tnot\n\tdup 1\n\tjz oufim%d\n%s\tnot\n\tmul\noufim%d :  nop\n\tnot", $2, cou, $6, cou); cou++; }
      | Expr IG Expr                      { asprintf(&$$,"%s%s\tequal\n", $1, $3); }
      | Expr DIF Expr                     { asprintf(&$$,"%s%s\tinf\n%s%s\tsup\n\tadd\n", $1, $3,$1,$3); }
      | Expr IME Expr                     { asprintf(&$$,"%s%s\tinfeq\n", $1, $3); }
      | Expr IMA Expr                     { asprintf(&$$,"%s%s\tsupeq\n", $1, $3); }
      | Expr MA Expr                      { asprintf(&$$,"%s%s\tsup\n", $1, $3); }
      | Expr ME Expr                      { asprintf(&$$,"%s%s\tinf\n", $1, $3); }
      ;

Atrib : ID '=' Expr     {  HASH_FIND_STR(users, $1, s); 
                           if (s) { 
                           if ((s->category == Var) && (s->tipo == Int)) { 
                              asprintf(&$$,"%s\tstoreg %d\n", $3, s->end);
                              } 
                              else { printf("\n\n   Erro Desconhecido 4  \n\n"); }
                           } 
                           else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                        }
      | ID '=' SC    { HASH_FIND_STR(users, $1, s); 
                           if (s) { 
                           if ((s->category == Var) && (s->tipo == Int)) { 
                              asprintf(&$$,"\tread\n\tatoi\n\tstoreg %d\n",s->end);
                              } 
                              else { printf("\n\n   Erro Desconhecido 5  \n\n"); }
                           } 
                           else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                          }
      | ID '(' Expr ')' '=' Expr  {  // opção para alterar a uma certa posição do array
                                    HASH_FIND_STR( users, $1, s); 
                                    if (s) { 
                                      if ((s->category == Array) && (s->tipo == Arr)) {
                                        char *error_str = errArr($1, $3, s->dim, &carr);
                                        asprintf(&$$,"%s\tpushgp\n\tpushi %d\n\tpadd\n%s%s\tstoren\n", error_str,s->end,$3,$6);
                                      } 
                                      else { printf("\n\n   Erro Desconhecido 1  \n\n"); }
                                    } 
                                    else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                                 }
      | ID '(' Expr ')' '=' SC    { HASH_FIND_STR( users, $1, s); 
                                    if (s) { 
                                      if ((s->category == Array) && (s->tipo == Arr)) {
                                        char *error_str = errArr($1, $3, s->dim, &carr);
                                        asprintf(&$$,"%s\tpushgp\n\tpushi %d\n\tpadd\n%s\tread\n\tatoi\n\tstoren\n", error_str,s->end,$3);
                                      } 
                                      else { printf("\n\n   Erro Desconhecido 3  \n\n"); }
                                    } 
                                    else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                                  }
      ;
 

Expr  : Termo             { asprintf(&$$,"%s", $1); }
      | Expr '+' Termo    { asprintf(&$$,"%s%s\tadd\n", $1, $3);}
      | Expr '-' Termo    { asprintf(&$$,"%s%s\tsub\n", $1, $3);}
      ;

Termo : Fator              { asprintf(&$$,"%s", $1);}
      | Termo '*' Fator    { asprintf(&$$,"%s%s\tmul\n", $1, $3);}
      | Termo '/' Fator    { asprintf(&$$,"%s%s\tdiv\n", $1, $3);}
      | Termo MOD Fator    { asprintf(&$$,"%s%s\tmod\n", $3, $1);}
      ;

Fator : NUM             { asprintf(&$$,"\tpushi %d\n", $1);}
      | '-' NUM         { asprintf(&$$,"\tpushi -%d\n", $2);}
      | TRUE            { asprintf(&$$,"\tpushi 1\n");}
      | FALSE           { asprintf(&$$,"\tpushi 0\n"); }
      | '(' Expr ')'    { asprintf(&$$,"\tpushi %d\n", $2);}
      | ID                           { HASH_FIND_STR( users, $1, s); 
                                       if (s) { 
                                             if ((s->category == Var) && (s->tipo == Int)) { 
                                                   asprintf(&$$,"\tpushg %d\n", s->end);
                                             } else { printf("\n\n   Erro Desconhecido   \n\n"); }
                                       } else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1); }
                                     }
      | ID '(' Expr ')'              {  HASH_FIND_STR( users, $1, s); 
                                        if (s) { 
                                          if ((s->category == Array) && (s->tipo == Arr)) {
                                          char *error_str = errArr($1, $3, s->dim, &carr);
                                          asprintf(&$$,"%s\tpushgp\n\tpushi %d\n\tpadd\n%s\tloadn\n", error_str,s->end,$3);
                                        } 
                                        else { printf("\n\n   Erro Desconhecido 1  \n\n"); }
                                      } 
                                      else { printf("\n\n Erro : foi tentado utilizar a variável %s quando esta não foi inicializada \n\n", $1);}
                                      }
      ;

%%

#include "lex.yy.c"
void yyerror (char* s){ printf("%s\n",s);}

char *errArr (char *id, char *expr, int dim, int *count) {
    char *r, *inferior, *greater, *error_str;
    asprintf (&greater, "%s\tpushi %d\n\tsupeq\n\tjz func%d\n\terr \"tentativa de acesso a posicao inexistente do array %s\"\n\tstop\nfunc%d: nop\n", 
                expr, dim, *count, id, *count);
    asprintf (&inferior, "%s\tpushi 0\n\tinf\n\tjz func%d\n\terr \"tentativa de acesso a posicao menor do que 0 do array %s\"\n\tstop\nfunc%d: nop\n", 
                expr, *count + 1, id,*count + 1);
    asprintf (&error_str, "%s%s", inferior, greater);
    *count = *count + 2;

    return error_str;
}

char *errInicArr (char *id, char *expr, int *count) {
    char *r, *inferior, *error_str;
    asprintf (&inferior, "%s\tpushi 0\n\tinf\n\tjz func%d\n\terr \"tentativa de acesso a posicao menor do que 0 do array %s\"\n\tstop\nfunc%d: nop\n", 
                expr, *count + 1, id,*count + 1);
    asprintf (&error_str, "%s", inferior);
    *count = *count + 1;

    return error_str;
}

int main() {
      exe = fopen ("execute.vm", "w");
      char tp[20];
      yyparse();

      for(s=users; s != NULL; s=(struct my_struct*)(s->hh.next)) {
            printf("user id %d: name %s\n           end %d\n           category %d\n           tipo %d\n           dim %d\n\n", s->end, s->name, s->end, s->category, s->tipo, s->dim);
      }

      /* free the hash table contents */
      HASH_ITER(hh, users, s, tmp) {
            printf("\n%s\n",s->name);  
            HASH_DEL(users, s);
            free(s);
      }
      fclose (exe);
      return 0;
}