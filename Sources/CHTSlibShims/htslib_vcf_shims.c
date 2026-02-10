/*
 * htslib_vcf_shims.c -- Non-inline C wrappers for VCF/BCF macros and inline
 *                       functions from htslib/vcf.h that Swift cannot import
 *                       directly.
 *
 * Each function simply delegates to the original macro or inline function
 * so that a real symbol is emitted for the linker.
 */

#include "include/htslib_vcf_shims.h"

/* ── Macro wrappers ─────────────────────────────────────────────────────── */

int32_t hts_shim_bcf_hdr_nsamples(const bcf_hdr_t *hdr)
{
    return bcf_hdr_nsamples(hdr);
}

htsFile *hts_shim_bcf_open(const char *fn, const char *mode)
{
    return bcf_open(fn, mode);
}

int hts_shim_bcf_close(htsFile *fp)
{
    return bcf_close(fp);
}

bcf1_t *hts_shim_bcf_init1(void)
{
    return bcf_init1();
}

void hts_shim_bcf_destroy1(bcf1_t *v)
{
    bcf_destroy1(v);
}

int hts_shim_bcf_read1(htsFile *fp, const bcf_hdr_t *h, bcf1_t *v)
{
    return bcf_read1(fp, h, v);
}

int hts_shim_bcf_write1(htsFile *fp, bcf_hdr_t *h, bcf1_t *v)
{
    return bcf_write1(fp, h, v);
}

/* ── INFO update macro wrappers ─────────────────────────────────────────── */

int hts_shim_bcf_update_info_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                   const char *key, const int32_t *values,
                                   int n)
{
    return bcf_update_info_int32(hdr, line, key, values, n);
}

int hts_shim_bcf_update_info_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                   const char *key, const float *values,
                                   int n)
{
    return bcf_update_info_float(hdr, line, key, values, n);
}

int hts_shim_bcf_update_info_flag(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const char *key, const char *string,
                                  int n)
{
    return bcf_update_info_flag(hdr, line, key, string, n);
}

int hts_shim_bcf_update_info_string(const bcf_hdr_t *hdr, bcf1_t *line,
                                    const char *key, const char *string)
{
    return bcf_update_info_string(hdr, line, key, string);
}

/* ── FORMAT update macro wrappers ───────────────────────────────────────── */

int hts_shim_bcf_update_format_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                     const char *key, const int32_t *values,
                                     int n)
{
    return bcf_update_format_int32(hdr, line, key, values, n);
}

int hts_shim_bcf_update_format_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                     const char *key, const float *values,
                                     int n)
{
    return bcf_update_format_float(hdr, line, key, values, n);
}

int hts_shim_bcf_update_format_char(const bcf_hdr_t *hdr, bcf1_t *line,
                                    const char *key, const char *values,
                                    int n)
{
    return bcf_update_format_char(hdr, line, key, values, n);
}

int hts_shim_bcf_update_genotypes(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const int32_t *gts, int n)
{
    return bcf_update_genotypes(hdr, line, gts, n);
}

/* ── INFO get macro wrappers ────────────────────────────────────────────── */

int hts_shim_bcf_get_info_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                const char *tag, int32_t **dst, int *ndst)
{
    return bcf_get_info_int32(hdr, line, tag, dst, ndst);
}

int hts_shim_bcf_get_info_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                const char *tag, float **dst, int *ndst)
{
    return bcf_get_info_float(hdr, line, tag, dst, ndst);
}

int hts_shim_bcf_get_info_string(const bcf_hdr_t *hdr, bcf1_t *line,
                                 const char *tag, uint8_t **dst, int *ndst)
{
    return bcf_get_info_string(hdr, line, tag, dst, ndst);
}

int hts_shim_bcf_get_info_flag(const bcf_hdr_t *hdr, bcf1_t *line,
                               const char *tag, void **dst, int *ndst)
{
    return bcf_get_info_flag(hdr, line, tag, dst, ndst);
}

/* ── FORMAT get macro wrappers ──────────────────────────────────────────── */

int hts_shim_bcf_get_format_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const char *tag, int32_t **dst, int *ndst)
{
    return bcf_get_format_int32(hdr, line, tag, dst, ndst);
}

int hts_shim_bcf_get_format_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const char *tag, float **dst, int *ndst)
{
    return bcf_get_format_float(hdr, line, tag, dst, ndst);
}

int hts_shim_bcf_get_format_char(const bcf_hdr_t *hdr, bcf1_t *line,
                                 const char *tag, uint8_t **dst, int *ndst)
{
    return bcf_get_format_char(hdr, line, tag, dst, ndst);
}

int hts_shim_bcf_get_genotypes(const bcf_hdr_t *hdr, bcf1_t *line,
                               int32_t **dst, int *ndst)
{
    return bcf_get_genotypes(hdr, line, dst, ndst);
}

/* ── Genotype encoding/decoding macro wrappers ──────────────────────────── */

int32_t hts_shim_bcf_gt_phased(int idx)
{
    return bcf_gt_phased(idx);
}

int32_t hts_shim_bcf_gt_unphased(int idx)
{
    return bcf_gt_unphased(idx);
}

int32_t hts_shim_bcf_gt_missing(void)
{
    return bcf_gt_missing;
}

int hts_shim_bcf_gt_is_missing(int32_t val)
{
    return bcf_gt_is_missing(val);
}

int hts_shim_bcf_gt_is_phased(int32_t val)
{
    return bcf_gt_is_phased(val);
}

int hts_shim_bcf_gt_allele(int32_t val)
{
    return bcf_gt_allele(val);
}

int hts_shim_bcf_alleles2gt(int a, int b)
{
    return bcf_alleles2gt(a, b);
}

/* ── Missing/vector-end sentinel macro wrappers ─────────────────────────── */

int32_t hts_shim_bcf_int32_missing(void)
{
    return bcf_int32_missing;
}

int32_t hts_shim_bcf_int32_vector_end(void)
{
    return bcf_int32_vector_end;
}

/* ── Header access macro wrappers ──────────────────────────────────────── */

const char *hts_shim_bcf_hdr_int2id(const bcf_hdr_t *hdr, int type, int int_id)
{
    return bcf_hdr_int2id(hdr, type, int_id);
}

/* ── Inline function wrappers ───────────────────────────────────────────── */

void hts_shim_bcf_float_set(float *ptr, uint32_t value)
{
    bcf_float_set(ptr, value);
}

int hts_shim_bcf_float_is_missing(float f)
{
    return bcf_float_is_missing(f);
}

int hts_shim_bcf_float_is_vector_end(float f)
{
    return bcf_float_is_vector_end(f);
}

int hts_shim_bcf_format_gt(bcf_fmt_t *fmt, int isample, kstring_t *str)
{
    return bcf_format_gt(fmt, isample, str);
}

int hts_shim_bcf_enc_size(kstring_t *s, int size, int type)
{
    return bcf_enc_size(s, size, type);
}

int64_t hts_shim_bcf_dec_int1(const uint8_t *p, int type, uint8_t **q)
{
    return bcf_dec_int1(p, type, q);
}

int64_t hts_shim_bcf_dec_typed_int1(const uint8_t *p, uint8_t **q)
{
    return bcf_dec_typed_int1(p, q);
}

void hts_shim_bcf_gt2alleles(int igt, int *a, int *b)
{
    bcf_gt2alleles(igt, a, b);
}

/* ── BCF index/iterator macro wrappers ──────────────────────────────────── */

hts_itr_t *hts_shim_bcf_itr_queryi(const hts_idx_t *idx, int tid, hts_pos_t beg, hts_pos_t end)
{
    return bcf_itr_queryi(idx, tid, beg, end);
}

hts_itr_t *hts_shim_bcf_itr_querys(const hts_idx_t *idx, bcf_hdr_t *hdr, const char *s)
{
    return bcf_itr_querys(idx, hdr, s);
}

int hts_shim_bcf_itr_next(htsFile *htsfp, hts_itr_t *itr, bcf1_t *r)
{
    return bcf_itr_next(htsfp, itr, r);
}

/* ── Synced BCF reader macro/variadic wrappers ──────────────────────────── */

int hts_shim_bcf_sr_has_line(bcf_srs_t *readers, int i)
{
    return bcf_sr_has_line(readers, i);
}

bcf1_t *hts_shim_bcf_sr_get_line(bcf_srs_t *readers, int i)
{
    return bcf_sr_get_line(readers, i);
}

bcf_hdr_t *hts_shim_bcf_sr_get_header(bcf_srs_t *readers, int i)
{
    return bcf_sr_get_header(readers, i);
}

int hts_shim_bcf_sr_set_opt_pair_logic(bcf_srs_t *readers, int logic)
{
    return bcf_sr_set_opt(readers, BCF_SR_PAIR_LOGIC, logic);
}

int hts_shim_bcf_sr_set_opt_require_idx(bcf_srs_t *readers)
{
    return bcf_sr_set_opt(readers, BCF_SR_REQUIRE_IDX);
}

int hts_shim_bcf_sr_set_opt_allow_no_idx(bcf_srs_t *readers)
{
    return bcf_sr_set_opt(readers, BCF_SR_ALLOW_NO_IDX);
}

int hts_shim_bcf_sr_set_opt_regions_overlap(bcf_srs_t *readers, int overlap)
{
    return bcf_sr_set_opt(readers, BCF_SR_REGIONS_OVERLAP, overlap);
}

int hts_shim_bcf_sr_set_opt_targets_overlap(bcf_srs_t *readers, int overlap)
{
    return bcf_sr_set_opt(readers, BCF_SR_TARGETS_OVERLAP, overlap);
}
