/*
 * htslib_hfile_shims.c
 *
 * Non-inline C wrappers for hFILE inline functions
 * from htslib/hfile.h that Swift cannot import directly.
 *
 * Each function delegates to the original inline function.
 */

#include "include/htslib_hfile_shims.h"

// ---------------------------------------------------------------------------
// Error handling
// ---------------------------------------------------------------------------

int hts_shim_herrno(hFILE *fp) {
    return herrno(fp);
}

void hts_shim_hclearerr(hFILE *fp) {
    hclearerr(fp);
}

// ---------------------------------------------------------------------------
// Position
// ---------------------------------------------------------------------------

off_t hts_shim_htell(hFILE *fp) {
    return htell(fp);
}

// ---------------------------------------------------------------------------
// Reading
// ---------------------------------------------------------------------------

int hts_shim_hgetc(hFILE *fp) {
    return hgetc(fp);
}

ssize_t hts_shim_hgetln(char *buffer, size_t size, hFILE *fp) {
    return hgetln(buffer, size, fp);
}

ssize_t hts_shim_hread(hFILE *fp, void *buffer, size_t nbytes) {
    return hread(fp, buffer, nbytes);
}

// ---------------------------------------------------------------------------
// Writing
// ---------------------------------------------------------------------------

int hts_shim_hputc(int c, hFILE *fp) {
    return hputc(c, fp);
}

int hts_shim_hputs(const char *text, hFILE *fp) {
    return hputs(text, fp);
}

ssize_t hts_shim_hwrite(hFILE *fp, const void *buffer, size_t nbytes) {
    return hwrite(fp, buffer, nbytes);
}

// ---------------------------------------------------------------------------
// Open/Close
// ---------------------------------------------------------------------------

hFILE *hts_shim_hopen(const char *filename, const char *mode) {
    return hopen(filename, mode);
}
