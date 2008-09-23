#ifndef TOKEN_H
#define TOKEN_H
typedef struct token_s {
  unsigned int op;
  
  const char *string;
  
  struct token_s *left, *right;
} token_t;

typedef token_t *token;

void print_tree(token tok,int depth);
token make_node(int op,const char *str,token left, token right);
#endif
