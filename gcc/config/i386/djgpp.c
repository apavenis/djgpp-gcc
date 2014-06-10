/* Subroutines for DJGPP.
   Contributed by Andris Pavenis <andris.pavenis@iki.fi>
   Copyright (C) 2013 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with GCC; see the file COPYING3.  If not see
<http://www.gnu.org/licenses/>.  */

#include "config.h"
#include "system.h"
#include "coretypes.h"
#include "tm.h"
#include "rtl.h"
#include "regs.h"
#include "hard-reg-set.h"
#include "output.h"
#include "tree.h"
#include "ggc.h"
#include "target.h"
#include "vec.h"
#include "basic-block.h"
#include "tree-ssa-alias.h"
#include "internal-fn.h"
#include "gimple-fold.h"
#include "tree-eh.h"
#include "gimple-expr.h"
#include "is-a.h"
#include "gimple.h"
#include "lto-section-names.h"

void
i386_djgpp_asm_named_section(const char *name, unsigned int flags,
			     tree decl)
{
  char flagchars[8], *f = flagchars;

(void)decl; /* silence warning. */

  if (flags & SECTION_WRITE)
    *f++ = 'w';
  if (flags & SECTION_CODE)
    *f++ = 'x';

  /* LTO sections need 1-byte alignment to avoid confusing the
     zlib decompression algorithm with trailing zero pad bytes.  */
  if (strncmp (name, LTO_SECTION_NAME_PREFIX,
			strlen (LTO_SECTION_NAME_PREFIX)) == 0)
    *f++ = '0';

  *f++ = '\0';

  fprintf (asm_out_file, "\t.section\t%s,\"%s\"\n", name, flagchars);
}
