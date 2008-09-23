#ifndef FDL_FILE_H
#define FDL_FILE_H
#include <stdlib.h>
#include "token.h"

typedef struct fdl_file_s {
  token head;
  
  struct fdl_file_s *next;
} fdl_file_t;

typedef fdl_file_t *fdl_file;

fdl_file add_to_file(fdl_file file, token token);
void print_parse(fdl_file file);
#endif
