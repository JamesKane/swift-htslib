/*
 * htslib_index_shims.c
 *
 * Non-inline C wrappers for index-related and endian-swap inline functions
 * from htslib/hts.h that Swift cannot import directly.
 *
 * Each function delegates to the original inline function.
 */

#include "include/htslib_index_shims.h"

// ---------------------------------------------------------------------------
// Binning index helpers
// ---------------------------------------------------------------------------

int hts_shim_hts_reg2bin(hts_pos_t beg, hts_pos_t end, int min_shift, int n_lvls) {
    return hts_reg2bin(beg, end, min_shift, n_lvls);
}

int hts_shim_hts_bin_level(int bin) {
    return hts_bin_level(bin);
}

// ---------------------------------------------------------------------------
// Endianness detection and byte swapping
// ---------------------------------------------------------------------------

int hts_shim_ed_is_big(void) {
    return ed_is_big();
}

uint16_t hts_shim_ed_swap_2(uint16_t v) {
    return ed_swap_2(v);
}

void *hts_shim_ed_swap_2p(void *x) {
    return ed_swap_2p(x);
}

uint32_t hts_shim_ed_swap_4(uint32_t v) {
    return ed_swap_4(v);
}

void *hts_shim_ed_swap_4p(void *x) {
    return ed_swap_4p(x);
}

uint64_t hts_shim_ed_swap_8(uint64_t v) {
    return ed_swap_8(v);
}

void *hts_shim_ed_swap_8p(void *x) {
    return ed_swap_8p(x);
}
