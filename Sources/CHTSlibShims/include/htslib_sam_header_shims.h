/*
 * htslib_sam_header_shims.h
 *
 * Non-variadic C wrappers for sam_hdr_add_line() and sam_hdr_add_pg()
 * which are variadic and cannot be imported by Swift directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_SAM_HEADER_SHIMS_H
#define HTSLIB_SAM_HEADER_SHIMS_H

#include <htslib/sam.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Add a header line with one key-value pair.
int hts_shim_sam_hdr_add_line_1(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1);

/// Add a header line with two key-value pairs.
int hts_shim_sam_hdr_add_line_2(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2);

/// Add a header line with three key-value pairs.
int hts_shim_sam_hdr_add_line_3(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2,
                                const char *k3, const char *v3);

/// Add a header line with four key-value pairs.
int hts_shim_sam_hdr_add_line_4(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2,
                                const char *k3, const char *v3,
                                const char *k4, const char *v4);

/// Add a header line with five key-value pairs.
int hts_shim_sam_hdr_add_line_5(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2,
                                const char *k3, const char *v3,
                                const char *k4, const char *v4,
                                const char *k5, const char *v5);

/// Add a @PG line with just the ID field.
int hts_shim_sam_hdr_add_pg_1(sam_hdr_t *h, const char *name,
                              const char *k1, const char *v1);

/// Add a @PG line with two extra key-value pairs.
int hts_shim_sam_hdr_add_pg_2(sam_hdr_t *h, const char *name,
                              const char *k1, const char *v1,
                              const char *k2, const char *v2);

/// Add a @PG line with three extra key-value pairs.
int hts_shim_sam_hdr_add_pg_3(sam_hdr_t *h, const char *name,
                              const char *k1, const char *v1,
                              const char *k2, const char *v2,
                              const char *k3, const char *v3);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_SAM_HEADER_SHIMS_H */
