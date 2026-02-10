/*
 * htslib_cram_shims.h
 *
 * Non-variadic C wrappers for hts_set_opt() which is variadic and
 * cannot be imported by Swift directly, plus CRAM helper accessors.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_CRAM_SHIMS_H
#define HTSLIB_CRAM_SHIMS_H

#include <htslib/hts.h>
#include <htslib/cram.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Set an integer option on an htsFile (wraps hts_set_opt with int argument).
int hts_shim_set_opt_int(htsFile *fp, enum hts_fmt_option opt, int val);

/// Set a string option on an htsFile (wraps hts_set_opt with char* argument).
int hts_shim_set_opt_str(htsFile *fp, enum hts_fmt_option opt, const char *val);

/// Extract the cram_fd pointer from an htsFile.
/// Returns NULL if the file is not a CRAM file.
cram_fd *hts_shim_hts_get_cram_fd(htsFile *fp);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_CRAM_SHIMS_H */
