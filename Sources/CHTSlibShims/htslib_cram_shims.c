/*
 * htslib_cram_shims.c
 *
 * Non-variadic C wrappers for hts_set_opt() which is variadic and
 * cannot be imported by Swift directly, plus CRAM helper accessors.
 */

#include "include/htslib_cram_shims.h"
#include <stddef.h>

int hts_shim_set_opt_int(htsFile *fp, enum hts_fmt_option opt, int val)
{
    return hts_set_opt(fp, opt, val);
}

int hts_shim_set_opt_str(htsFile *fp, enum hts_fmt_option opt, const char *val)
{
    return hts_set_opt(fp, opt, val);
}

cram_fd *hts_shim_hts_get_cram_fd(htsFile *fp)
{
    if (!fp || fp->format.format != cram)
        return NULL;
    return fp->fp.cram;
}
