/*
 * htslib_tabix_shims.c
 *
 * Non-inline C wrappers for tabix macros
 * from htslib/tbx.h that Swift cannot import directly.
 *
 * Each function delegates to the original macro.
 */

#include "include/htslib_tabix_shims.h"

// ---------------------------------------------------------------------------
// Tabix iterator macros
// ---------------------------------------------------------------------------

void hts_shim_tbx_itr_destroy(hts_itr_t *iter) {
    tbx_itr_destroy(iter);
}

hts_itr_t *hts_shim_tbx_itr_queryi(tbx_t *tbx, int tid, hts_pos_t beg, hts_pos_t end) {
    return tbx_itr_queryi(tbx, tid, beg, end);
}

hts_itr_t *hts_shim_tbx_itr_querys(tbx_t *tbx, const char *s) {
    return tbx_itr_querys(tbx, s);
}

int hts_shim_tbx_itr_next(htsFile *htsfp, tbx_t *tbx, hts_itr_t *itr, void *r) {
    return tbx_itr_next(htsfp, tbx, itr, r);
}
