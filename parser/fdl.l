%{

#include <stdio.h>
#include "token.h"
#define YYSTYPE token
#include "fdl.tab.h"

extern token yylval;

int make_token(int op);
int make_string(const char *str,int type);
%}

%%
(true|TRUE|True) { return make_token(TRUE); }
(false|FALSE|False) { return make_token(FALSE); }
feature     { return make_token(FEATUREDEF); }
node        { return make_token(NODEDEF); }
"and"       { return make_token(AND); }
"or"        { return make_token(OR); }
"not("      { return make_token(NOT_LPAREN); }
"not"       { return make_token(NOT); }
"all"       { return make_token(ALL); }
[A-Za-z_0-9]+  { return make_string(yytext,STRING); }
\"[^\"]*\"  { return make_string(yytext,QSTRING); }
"<"         { return make_token(LVECTOR); }
">"         { return make_token(RVECTOR); }
"("         { return make_token(LPAREN); }
")"         { return make_token(RPAREN); }
","         { return make_token(COMMA); }
"."         { return make_token(DOT); }
"="         { return make_token(EQUALS); }
"!="        { return make_token(NOTEQUALS); }
":"         { return make_token(COLON); }
\"          { return make_token(QUOTE); }
"["         { return make_token(LBRACKET); }
"]"         { return make_token(RBRACKET); }
(\\|\/|\\\*|\/\*|\||<<|>>|>\*|<\*|<\||>\|)  { return make_string(yytext,TRAVERSE); }
[ \t]+      ;
"\n"        { yylineno++; }
#.*         ;
\'[^\']*\'      { return make_string(yytext,REGEX); }
%%

int make_token(int op) {
  yylval = (token)malloc(sizeof(struct token_s));
  yylval->op = op;
  yylval->string = NULL;
  yylval->left = NULL;
  yylval->right = NULL;
  return op;
}

int make_string(const char *str, int type) {
  yylval = (token)malloc(sizeof(struct token_s));
  yylval->op = type;
  yylval->string = (char *)malloc(sizeof(char)*strlen(str)+1);
  yylval->string = strcpy((char *)yylval->string,str);
  yylval->left = NULL;
  yylval->right = NULL;
  return type;
}
