/*
 * htslib_kstring_shims.c
 *
 * Non-inline C wrappers for kstring inline functions
 * from htslib/kstring.h that Swift cannot import directly.
 *
 * Each function delegates to the original inline function.
 */

#include "include/htslib_kstring_shims.h"

// ---------------------------------------------------------------------------
// Initialization and lifecycle
// ---------------------------------------------------------------------------

void hts_shim_ks_initialize(kstring_t *s) {
    ks_initialize(s);
}

int hts_shim_ks_resize(kstring_t *s, size_t size) {
    return ks_resize(s, size);
}

char *hts_shim_ks_str(kstring_t *s) {
    return ks_str(s);
}

size_t hts_shim_ks_len(kstring_t *s) {
    return ks_len(s);
}

kstring_t *hts_shim_ks_clear(kstring_t *s) {
    return ks_clear(s);
}

char *hts_shim_ks_release(kstring_t *s) {
    return ks_release(s);
}

void hts_shim_ks_free(kstring_t *s) {
    ks_free(s);
}

// ---------------------------------------------------------------------------
// Append operations
// ---------------------------------------------------------------------------

int hts_shim_kputsn(const char *p, size_t l, kstring_t *s) {
    return kputsn(p, l, s);
}

int hts_shim_kputs(const char *p, kstring_t *s) {
    return kputs(p, s);
}

int hts_shim_kputc(int c, kstring_t *s) {
    return kputc(c, s);
}

int hts_shim_kputw(int c, kstring_t *s) {
    return kputw(c, s);
}

int hts_shim_kputll(long long c, kstring_t *s) {
    return kputll(c, s);
}
