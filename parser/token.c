#include <stdio.h>
#include <stdlib.h>
#include "token.h"
#include "fdl.tab.h"

char *id_to_str(int id) {
  char buffer[10];
  switch(id) {
    case TRUE: printf("TRUE"); break;
    case FALSE: printf("FALSE"); break;
    case PREDICATE: printf("PREDICATE"); break;
    case FEATUREDEF: printf("FEATURE"); break;
    case NODEDEF: printf("NODE"); break;
    case STRING: printf("STRING"); break;
    case DOT: printf("DOT"); break;
    case RVECTOR: printf("RVECTOR"); break;
    case NODEDESC: printf("NODEDESC"); break;
    case EXPR: printf("EXPR"); break;
    case TRAVERSE: printf("TRAVERSE"); break;
    case BIND: printf("BIND"); break;
    case EQUALS: printf("EQUALS"); break;
    case NOTEQUALS: printf("NOTEQUALS"); break;
    case AND: printf("AND"); break;
    case QSTRING: printf("QSTRING"); break;
    case QUANTIFIER: printf("QUANTIFIER"); break;
    case NOT: printf("NOT"); break;
    case OR: printf("OR"); break;
    case REGEX: printf("REGEX"); break;
    default: 
      printf("%d",id);
  }
}

void print_tree(token head,int depth) {
  int i=0;
  if(head == NULL)
    return;
    
  for(i=0;i<depth;i++)
    printf(" ");
  
  printf("%p:",head);
  id_to_str(head->op);
  if(head->string == NULL)
    head->string = "";
  printf(":%s:%p:%p\n",head->string,head->left,head->right);
  print_tree(head->left,depth+2);
  print_tree(head->right,depth+2);
}

token make_node(int op,const char *str,token left, token right) {
  token new = (token)malloc(sizeof(struct token_s));
  new->left=left;
  new->right=right;
  new->op=op;
  new->string=str;
  return new;
}
