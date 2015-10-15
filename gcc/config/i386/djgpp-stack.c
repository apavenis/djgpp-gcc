#include <crt0.h>

/*

The default stack size (512KB) for DJGPP applications is not
sufficient for several GCC executables like
cc1.exe, cc1plus.exe, etc.

Redefine it to larger value (2MB).

*/
int _stklen = 2097152;

int _crt0_startup_flags = _CRT0_DISABLE_SBRK_ADDRESS_WRAP;
