#include <stdio.h>
#include "fdl_file.h"
#include "fdl.tab.h"

fdl_file add_to_file(fdl_file file, token token) {
  fdl_file new = (fdl_file)malloc(sizeof(struct fdl_file_s));
  new->next = file;
  new->head = token;
  return new;
}

void print_parse(fdl_file file) {
  while(file->next != NULL) {
    print_tree(file->head,0);
    printf("\n");
    file = file->next;
  }
}
