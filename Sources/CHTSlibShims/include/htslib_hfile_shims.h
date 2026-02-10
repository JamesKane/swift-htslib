/*
 * htslib_hfile_shims.h
 *
 * Non-inline C wrappers for hFILE inline functions
 * from htslib/hfile.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_HFILE_SHIMS_H
#define HTSLIB_HFILE_SHIMS_H

#include <htslib/hfile.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Error handling
// ---------------------------------------------------------------------------

/// Return the stream's error indicator.
int hts_shim_herrno(hFILE *fp);

/// Clear the stream's error indicator.
void hts_shim_hclearerr(hFILE *fp);

// ---------------------------------------------------------------------------
// Position
// ---------------------------------------------------------------------------

/// Report the current stream offset.
off_t hts_shim_htell(hFILE *fp);

// ---------------------------------------------------------------------------
// Reading
// ---------------------------------------------------------------------------

/// Read one character from the stream.
int hts_shim_hgetc(hFILE *fp);

/// Read a line from the stream, up to a maximum length.
ssize_t hts_shim_hgetln(char *buffer, size_t size, hFILE *fp);

/// Read a block of characters from the file.
ssize_t hts_shim_hread(hFILE *fp, void *buffer, size_t nbytes);

// ---------------------------------------------------------------------------
// Writing
// ---------------------------------------------------------------------------

/// Write a character to the stream.
int hts_shim_hputc(int c, hFILE *fp);

/// Write a string to the stream.
int hts_shim_hputs(const char *text, hFILE *fp);

/// Write a block of characters to the file.
ssize_t hts_shim_hwrite(hFILE *fp, const void *buffer, size_t nbytes);

// ---------------------------------------------------------------------------
// Open/Close (hopen is variadic, not importable by Swift)
// ---------------------------------------------------------------------------

/// Open the named file or URL as a stream. Non-variadic wrapper around hopen().
hFILE *hts_shim_hopen(const char *filename, const char *mode);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_HFILE_SHIMS_H */
