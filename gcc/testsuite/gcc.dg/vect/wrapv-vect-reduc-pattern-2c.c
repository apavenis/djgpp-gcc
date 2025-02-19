/* { dg-additional-options "-fwrapv" } */
/* { dg-require-effective-target vect_int } */

#include <stdarg.h>
#include "tree-vect.h"

#define N 16
signed char data_ch[N] =
  { 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28 };
#define SUM 210

__attribute__ ((noinline)) int
foo ()
{
  int i;
  signed short shortsum = 0;

  /* widenning sum: sum chars into short.  */

  for (i = 0; i < N; i++)
    {
      shortsum += data_ch[i];
    }

  /* check results:  */
  if (shortsum != SUM)
    abort ();

  return 0;
}

int
main (void)
{
  check_vect ();
  return foo ();
}

/* { dg-final { scan-tree-dump "vect_recog_widen_sum_pattern: detected" "vect" } } */
/* { dg-final { scan-tree-dump-times "vectorized 1 loops" 1 "vect" { target vect_widen_sum_qi_to_hi } } } */
/* { dg-final { scan-tree-dump-times "vectorized 1 loops" 0 "vect" { target { ! vect_widen_sum_qi_to_hi } } } } */
