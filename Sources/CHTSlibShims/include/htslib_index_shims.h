/*
 * htslib_index_shims.h
 *
 * Non-inline C wrappers for index-related and endian-swap inline functions
 * from htslib/hts.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_INDEX_SHIMS_H
#define HTSLIB_INDEX_SHIMS_H

#include <htslib/hts.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Binning index helpers
// ---------------------------------------------------------------------------

/// Compute the bin number for a genomic region.
int hts_shim_hts_reg2bin(hts_pos_t beg, hts_pos_t end, int min_shift, int n_lvls);

/// Compute the level of a given bin.
int hts_shim_hts_bin_level(int bin);

// ---------------------------------------------------------------------------
// Endianness detection and byte swapping
// ---------------------------------------------------------------------------

/// Check whether the platform is big-endian.
int hts_shim_ed_is_big(void);

/// Byte-swap a 16-bit value.
uint16_t hts_shim_ed_swap_2(uint16_t v);

/// Byte-swap a 16-bit value in place.
void *hts_shim_ed_swap_2p(void *x);

/// Byte-swap a 32-bit value.
uint32_t hts_shim_ed_swap_4(uint32_t v);

/// Byte-swap a 32-bit value in place.
void *hts_shim_ed_swap_4p(void *x);

/// Byte-swap a 64-bit value.
uint64_t hts_shim_ed_swap_8(uint64_t v);

/// Byte-swap a 64-bit value in place.
void *hts_shim_ed_swap_8p(void *x);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_INDEX_SHIMS_H */
