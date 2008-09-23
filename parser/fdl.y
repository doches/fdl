%{
#include <stdio.h>
#include <string.h>
#include "token.h"
#include "fdl_file.h"
 
#define YYSTYPE token

extern int yylineno;
extern char *yytext;
 
void yyerror(const char *str)
{
        fprintf(stderr,"Error, line %i: %s near \"%s\"\n\n",yylineno,str,yytext);
        exit(1);
}

void yywarning(const char *str)
{
        fprintf(stderr,"Warning, line %i, near \"%s\": %s\n\n",yylineno,yytext,str);
}
 
int yywrap()
{
        return 1;
} 
  
int yydebug = 0;

fdl_file parse_result = NULL;

main(int argc)
{
        parse_result = (fdl_file)malloc(sizeof(struct fdl_file_s));
        parse_result->next = NULL;
        yydebug = (argc - 1);
        yyparse();
        print_parse(parse_result);
} 

%}

%token NODEDEF FEATUREDEF STRING REGEX QSTRING PREDICATE TRUE FALSE
%token TRAVERSE
%token AND OR NOT NOT_LPAREN
%token LPAREN RPAREN LBRACKET RBRACKET COLON EQUALS NOTEQUALS QUOTE
%token LVECTOR RVECTOR COMMA DOT ALL
%token NODEDESC EXPR BIND QUANTIFIER

%left AND OR
%right NOT

%start file

%%

file:
        definition
      | definition file
      ;

definition:
        feature { parse_result = add_to_file(parse_result,$1); }
      | node    { parse_result = add_to_file(parse_result,$1); }
      ;

feature:
        FEATUREDEF STRING expression return_vector { $$ = make_node(FEATUREDEF,$2->string, $3, $4); }
      | FEATUREDEF STRING expression               { $$ = make_node(FEATUREDEF,$2->string, $3, NULL); }
      ;

node:
        NODEDEF STRING expression node_return_vector { $$ = make_node(NODEDEF,$2->string, $3, $4); }
      ;
      
subexpression:
        TRUE                      { $$ = make_node(TRUE,NULL,NULL,NULL); }
      | FALSE                     { $$ = make_node(FALSE,NULL,NULL,NULL); }
      | path                      { $$ = make_node(EXPR,NULL,$1,NULL); }
      | quantifier                { $$ = $1 }
      | LPAREN expression RPAREN  { $$ = $2 }
      | STRING LPAREN predicate RPAREN   { $$ = make_node(PREDICATE,$1->string,$3,NULL); }
      | NOT expression                { $$ = make_node(NOT,NULL,$2,NULL); }
      ;

expression:
        subexpression                 { $$ = $1};
      | expression AND subexpression  { $$ = make_node(AND,NULL,$1,$3); }
      | expression OR subexpression   { $$ = make_node(OR,NULL,$1,$3); }
      | NOT_LPAREN expression RPAREN  { yywarning("Probable logic error in negation, rewrite as \"(not <expr>)\" or \"not (<expr>)\""); $$ = make_node(NOT,NULL,$2,NULL); }
      ;

predicate:
      | STRING  { $$ = make_node(STRING,$1->string,NULL,NULL); }
      ;

quantifier:
        ALL LPAREN STRING COMMA expression RPAREN  { $$ = make_node(QUANTIFIER,$3->string,$5,NULL); }
      ;
      
path:
        node                          { $$ = $1 }
      | node TRAVERSE path            { $$ = make_node(TRAVERSE,$2->string,$1,$3); }
      ;

node:
        STRING COLON noded            { $$ = make_node(BIND,$1->string,$3,NULL); }
      | noded                         { $$ = $1 }
      ;

noded:
        LBRACKET RBRACKET             { $$ = make_node(NODEDESC,NULL,NULL,NULL); }
      | LBRACKET node_exp RBRACKET    { $$ = make_node(NODEDESC,NULL,$2,NULL); }
      | STRING                        { $$ = make_node(NODEDESC,$1->string,NULL,NULL); }
      ;
      
node_exp:
        STRING EQUALS rvalue          { $$ = make_node(EQUALS,NULL,$1,$3); }
      | STRING NOTEQUALS rvalue       { $$ = make_node(NOTEQUALS,NULL,$1,$3); }
      | node_exp AND node_exp         { $$ = make_node(AND,NULL,$1,$3); }
      | node_exp OR node_exp          { $$ = make_node(OR,NULL,$1,$3); }
      | LPAREN node_exp RPAREN        { $$ = $2 }
      ;
      
rvalue:
        QSTRING { $$ = make_node(QSTRING,$1->string,NULL,NULL); }
      | STRING  { $$ = make_node(STRING,$1->string,NULL,NULL); }
      | REGEX   { $$ = make_node(REGEX,$1->string,NULL,NULL); }
      ;

return_vector:
        LVECTOR list RVECTOR { $$ = $2; }
      ;

node_return_vector:
        LVECTOR node_vector_list RVECTOR { $$ = make_node(RVECTOR,NULL,$2,NULL); }
      ;

list:
        listitem { $$ = $1 }
      | listitem COMMA list { $$ = make_node(RVECTOR, NULL, $1, $3); }
      ;
      
listitem:
        STRING DOT STRING { $$ = make_node(DOT,NULL,make_node(STRING,$1->string,NULL,NULL),make_node(STRING,$3->string,NULL,NULL)); }
      | QSTRING { $$ = make_node(STRING,$1->string,NULL,NULL); }
      ;

node_vector_list:
        STRING                         { $$ = make_node(STRING,$1->string,NULL,NULL); }
      | STRING COMMA node_vector_list  { $$ = make_node(STRING,$1->string,$3,NULL); }
      ;
%%
