/*
 * htslib_bgzf_shims.c
 *
 * Non-inline C wrappers for BGZF macros and inline functions
 * from htslib/bgzf.h that Swift cannot import directly.
 *
 * Each function delegates to the original macro or inline function.
 */

#include "include/htslib_bgzf_shims.h"

// ---------------------------------------------------------------------------
// bgzf_tell macro
// ---------------------------------------------------------------------------

int64_t hts_shim_bgzf_tell(BGZF *fp) {
    return bgzf_tell(fp);
}

// ---------------------------------------------------------------------------
// Inline read/write wrappers
// ---------------------------------------------------------------------------

ssize_t hts_shim_bgzf_read_small(BGZF *fp, void *data, size_t length) {
    return bgzf_read_small(fp, data, length);
}

ssize_t hts_shim_bgzf_write_small(BGZF *fp, const void *data, size_t length) {
    return bgzf_write_small(fp, data, length);
}
