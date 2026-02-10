/*
 * htslib_sam_header_shims.c
 *
 * Non-variadic C wrappers for sam_hdr_add_line() and sam_hdr_add_pg()
 * which are variadic and cannot be imported by Swift directly.
 */

#include "include/htslib_sam_header_shims.h"
#include <stddef.h>

int hts_shim_sam_hdr_add_line_1(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1)
{
    return sam_hdr_add_line(h, type, k1, v1, NULL);
}

int hts_shim_sam_hdr_add_line_2(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2)
{
    return sam_hdr_add_line(h, type, k1, v1, k2, v2, NULL);
}

int hts_shim_sam_hdr_add_line_3(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2,
                                const char *k3, const char *v3)
{
    return sam_hdr_add_line(h, type, k1, v1, k2, v2, k3, v3, NULL);
}

int hts_shim_sam_hdr_add_line_4(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2,
                                const char *k3, const char *v3,
                                const char *k4, const char *v4)
{
    return sam_hdr_add_line(h, type, k1, v1, k2, v2, k3, v3, k4, v4, NULL);
}

int hts_shim_sam_hdr_add_line_5(sam_hdr_t *h, const char *type,
                                const char *k1, const char *v1,
                                const char *k2, const char *v2,
                                const char *k3, const char *v3,
                                const char *k4, const char *v4,
                                const char *k5, const char *v5)
{
    return sam_hdr_add_line(h, type, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5, NULL);
}

int hts_shim_sam_hdr_add_pg_1(sam_hdr_t *h, const char *name,
                              const char *k1, const char *v1)
{
    return sam_hdr_add_pg(h, name, k1, v1, NULL);
}

int hts_shim_sam_hdr_add_pg_2(sam_hdr_t *h, const char *name,
                              const char *k1, const char *v1,
                              const char *k2, const char *v2)
{
    return sam_hdr_add_pg(h, name, k1, v1, k2, v2, NULL);
}

int hts_shim_sam_hdr_add_pg_3(sam_hdr_t *h, const char *name,
                              const char *k1, const char *v1,
                              const char *k2, const char *v2,
                              const char *k3, const char *v3)
{
    return sam_hdr_add_pg(h, name, k1, v1, k2, v2, k3, v3, NULL);
}
