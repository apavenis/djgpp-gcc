/* { dg-do compile { target { powerpc*-*-* } } } */
/* { dg-require-effective-target powerpc_vsx_ok } */
/* { dg-options "-mdejagnu-cpu=power9 -mvsx" } */

#include <altivec.h>

int
test_all_not_equal (vector bool char *arg1_p, vector bool char *arg2_p)
{
  vector bool char arg_1 = *arg1_p;
  vector bool char arg_2 = *arg2_p;

  return vec_all_ne (arg_1, arg_2);
}

/* { dg-final { scan-assembler "vcmpneb." } } */
