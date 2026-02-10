/*
 * htslib_tabix_shims.h
 *
 * Non-inline C wrappers for tabix macros
 * from htslib/tbx.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_TABIX_SHIMS_H
#define HTSLIB_TABIX_SHIMS_H

#include <htslib/hts.h>
#include <htslib/tbx.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Tabix iterator macros
// ---------------------------------------------------------------------------

/// Destroy a tabix iterator.
void hts_shim_tbx_itr_destroy(hts_itr_t *iter);

/// Create an iterator for a numeric region.
hts_itr_t *hts_shim_tbx_itr_queryi(tbx_t *tbx, int tid, hts_pos_t beg, hts_pos_t end);

/// Create an iterator from a region string.
hts_itr_t *hts_shim_tbx_itr_querys(tbx_t *tbx, const char *s);

/// Read the next record via a tabix iterator.
int hts_shim_tbx_itr_next(htsFile *htsfp, tbx_t *tbx, hts_itr_t *itr, void *r);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_TABIX_SHIMS_H */
