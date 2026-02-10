/*
 * htslib_bgzf_shims.h
 *
 * Non-inline C wrappers for BGZF macros and inline functions
 * from htslib/bgzf.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_BGZF_SHIMS_H
#define HTSLIB_BGZF_SHIMS_H

#include <htslib/bgzf.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// bgzf_tell macro
// ---------------------------------------------------------------------------

/// Return the virtual file pointer for the current position in the BGZF stream.
int64_t hts_shim_bgzf_tell(BGZF *fp);

// ---------------------------------------------------------------------------
// Inline read/write wrappers
// ---------------------------------------------------------------------------

/// Read a small number of bytes from a BGZF stream (optimised fast path).
ssize_t hts_shim_bgzf_read_small(BGZF *fp, void *data, size_t length);

/// Write a small number of bytes to a BGZF stream (optimised fast path).
ssize_t hts_shim_bgzf_write_small(BGZF *fp, const void *data, size_t length);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_BGZF_SHIMS_H */
