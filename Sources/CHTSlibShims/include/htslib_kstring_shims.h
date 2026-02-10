/*
 * htslib_kstring_shims.h
 *
 * Non-inline C wrappers for kstring inline functions
 * from htslib/kstring.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_KSTRING_SHIMS_H
#define HTSLIB_KSTRING_SHIMS_H

#include <htslib/kstring.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Initialization and lifecycle
// ---------------------------------------------------------------------------

/// Initialize a kstring_t to empty state.
void hts_shim_ks_initialize(kstring_t *s);

/// Resize a kstring to hold at least the given capacity.
int hts_shim_ks_resize(kstring_t *s, size_t size);

/// Return the underlying buffer pointer.
char *hts_shim_ks_str(kstring_t *s);

/// Return the current string length.
size_t hts_shim_ks_len(kstring_t *s);

/// Reset the kstring length to zero.
kstring_t *hts_shim_ks_clear(kstring_t *s);

/// Release ownership of the buffer, returning it and resetting the kstring.
char *hts_shim_ks_release(kstring_t *s);

/// Free the underlying buffer and reinitialize the kstring.
void hts_shim_ks_free(kstring_t *s);

// ---------------------------------------------------------------------------
// Append operations
// ---------------------------------------------------------------------------

/// Append a fixed-length byte string.
int hts_shim_kputsn(const char *p, size_t l, kstring_t *s);

/// Append a NUL-terminated string.
int hts_shim_kputs(const char *p, kstring_t *s);

/// Append a single character.
int hts_shim_kputc(int c, kstring_t *s);

/// Append a signed integer in decimal.
int hts_shim_kputw(int c, kstring_t *s);

/// Append a signed long long integer in decimal.
int hts_shim_kputll(long long c, kstring_t *s);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_KSTRING_SHIMS_H */
