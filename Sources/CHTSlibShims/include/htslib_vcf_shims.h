/*
 * htslib_vcf_shims.h -- Non-inline C wrappers for VCF/BCF macros and inline
 *                       functions from htslib/vcf.h that Swift cannot import
 *                       directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_VCF_SHIMS_H
#define HTSLIB_VCF_SHIMS_H

#include <htslib/vcf.h>
#include <htslib/synced_bcf_reader.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ── Macro wrappers ─────────────────────────────────────────────────────── */

/// Return the number of samples in a BCF header.
/// Wraps: bcf_hdr_nsamples(hdr) -> (hdr)->n[BCF_DT_SAMPLE]
int32_t hts_shim_bcf_hdr_nsamples(const bcf_hdr_t *hdr);

/// Open a VCF/BCF file.
/// Wraps: bcf_open(fn, mode) -> hts_open((fn), (mode))
htsFile *hts_shim_bcf_open(const char *fn, const char *mode);

/// Close a VCF/BCF file.
/// Wraps: bcf_close(fp) -> hts_close(fp)
int hts_shim_bcf_close(htsFile *fp);

/// Allocate and initialize a bcf1_t object.
/// Wraps: bcf_init1() -> bcf_init()
bcf1_t *hts_shim_bcf_init1(void);

/// Deallocate a bcf1_t object.
/// Wraps: bcf_destroy1(v) -> bcf_destroy(v)
void hts_shim_bcf_destroy1(bcf1_t *v);

/// Read one BCF/VCF record.
/// Wraps: bcf_read1(fp,h,v) -> bcf_read((fp),(h),(v))
int hts_shim_bcf_read1(htsFile *fp, const bcf_hdr_t *h, bcf1_t *v);

/// Write one BCF/VCF record.
/// Wraps: bcf_write1(fp,h,v) -> bcf_write((fp),(h),(v))
int hts_shim_bcf_write1(htsFile *fp, bcf_hdr_t *h, bcf1_t *v);

/* ── INFO update macro wrappers ─────────────────────────────────────────── */

/// Wraps: bcf_update_info_int32(hdr,line,key,values,n)
int hts_shim_bcf_update_info_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                   const char *key, const int32_t *values,
                                   int n);

/// Wraps: bcf_update_info_float(hdr,line,key,values,n)
int hts_shim_bcf_update_info_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                   const char *key, const float *values,
                                   int n);

/// Wraps: bcf_update_info_flag(hdr,line,key,string,n)
int hts_shim_bcf_update_info_flag(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const char *key, const char *string,
                                  int n);

/// Wraps: bcf_update_info_string(hdr,line,key,string)
int hts_shim_bcf_update_info_string(const bcf_hdr_t *hdr, bcf1_t *line,
                                    const char *key, const char *string);

/* ── FORMAT update macro wrappers ───────────────────────────────────────── */

/// Wraps: bcf_update_format_int32(hdr,line,key,values,n)
int hts_shim_bcf_update_format_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                     const char *key, const int32_t *values,
                                     int n);

/// Wraps: bcf_update_format_float(hdr,line,key,values,n)
int hts_shim_bcf_update_format_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                     const char *key, const float *values,
                                     int n);

/// Wraps: bcf_update_format_char(hdr,line,key,values,n)
int hts_shim_bcf_update_format_char(const bcf_hdr_t *hdr, bcf1_t *line,
                                    const char *key, const char *values,
                                    int n);

/// Wraps: bcf_update_genotypes(hdr,line,gts,n)
int hts_shim_bcf_update_genotypes(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const int32_t *gts, int n);

/* ── INFO get macro wrappers ────────────────────────────────────────────── */

/// Wraps: bcf_get_info_int32(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_info_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                const char *tag, int32_t **dst, int *ndst);

/// Wraps: bcf_get_info_float(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_info_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                const char *tag, float **dst, int *ndst);

/// Wraps: bcf_get_info_string(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_info_string(const bcf_hdr_t *hdr, bcf1_t *line,
                                 const char *tag, uint8_t **dst, int *ndst);

/// Wraps: bcf_get_info_flag(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_info_flag(const bcf_hdr_t *hdr, bcf1_t *line,
                               const char *tag, void **dst, int *ndst);

/* ── FORMAT get macro wrappers ──────────────────────────────────────────── */

/// Wraps: bcf_get_format_int32(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_format_int32(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const char *tag, int32_t **dst, int *ndst);

/// Wraps: bcf_get_format_float(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_format_float(const bcf_hdr_t *hdr, bcf1_t *line,
                                  const char *tag, float **dst, int *ndst);

/// Wraps: bcf_get_format_char(hdr,line,tag,dst,ndst)
int hts_shim_bcf_get_format_char(const bcf_hdr_t *hdr, bcf1_t *line,
                                 const char *tag, uint8_t **dst, int *ndst);

/// Wraps: bcf_get_genotypes(hdr,line,dst,ndst)
int hts_shim_bcf_get_genotypes(const bcf_hdr_t *hdr, bcf1_t *line,
                               int32_t **dst, int *ndst);

/* ── Genotype encoding/decoding macro wrappers ──────────────────────────── */

/// Encode a phased genotype allele index.
/// Wraps: bcf_gt_phased(idx) -> (((idx)+1)<<1|1)
int32_t hts_shim_bcf_gt_phased(int idx);

/// Encode an unphased genotype allele index.
/// Wraps: bcf_gt_unphased(idx) -> (((idx)+1)<<1)
int32_t hts_shim_bcf_gt_unphased(int idx);

/// Return the missing genotype value (0).
/// Wraps: bcf_gt_missing -> 0
int32_t hts_shim_bcf_gt_missing(void);

/// Test whether a genotype value represents a missing allele.
/// Wraps: bcf_gt_is_missing(val) -> ((val)>>1 ? 0 : 1)
int hts_shim_bcf_gt_is_missing(int32_t val);

/// Test whether a genotype value is phased.
/// Wraps: bcf_gt_is_phased(val) -> ((val)&1)
int hts_shim_bcf_gt_is_phased(int32_t val);

/// Extract the allele index from a genotype value.
/// Wraps: bcf_gt_allele(val) -> (((val)>>1)-1)
int hts_shim_bcf_gt_allele(int32_t val);

/// Convert allele pair to genotype index (diploid, 0-based).
/// Wraps: bcf_alleles2gt(a,b)
int hts_shim_bcf_alleles2gt(int a, int b);

/* ── Missing/vector-end sentinel macro wrappers ─────────────────────────── */

/// Return the int32 missing sentinel value (INT32_MIN).
/// Wraps: bcf_int32_missing
int32_t hts_shim_bcf_int32_missing(void);

/// Return the int32 vector-end sentinel value (INT32_MIN+1).
/// Wraps: bcf_int32_vector_end
int32_t hts_shim_bcf_int32_vector_end(void);

/* ── Header access macro wrappers ──────────────────────────────────────── */

/// Look up a header dictionary key by integer ID.
/// Wraps: bcf_hdr_int2id(hdr,type,int_id) -> (hdr)->id[type][int_id].key
const char *hts_shim_bcf_hdr_int2id(const bcf_hdr_t *hdr, int type, int int_id);

/* ── Inline function wrappers ───────────────────────────────────────────── */

/// Set a float from its raw uint32 bit representation.
/// Wraps: static inline void bcf_float_set(float *ptr, uint32_t value)
void hts_shim_bcf_float_set(float *ptr, uint32_t value);

/// Test whether a float value is the BCF missing sentinel.
/// Wraps: static inline int bcf_float_is_missing(float f)
int hts_shim_bcf_float_is_missing(float f);

/// Test whether a float value is the BCF vector-end sentinel.
/// Wraps: static inline int bcf_float_is_vector_end(float f)
int hts_shim_bcf_float_is_vector_end(float f);

/// Format a genotype sample as a string.
/// Wraps: static inline int bcf_format_gt(bcf_fmt_t *fmt, int isample,
///        kstring_t *str)
int hts_shim_bcf_format_gt(bcf_fmt_t *fmt, int isample, kstring_t *str);

/// Encode a type+size pair into a BCF byte stream.
/// Wraps: static inline int bcf_enc_size(kstring_t *s, int size, int type)
int hts_shim_bcf_enc_size(kstring_t *s, int size, int type);

/// Decode a single typed integer from a BCF byte stream.
/// Wraps: static inline int64_t bcf_dec_int1(const uint8_t *p, int type,
///        uint8_t **q)
int64_t hts_shim_bcf_dec_int1(const uint8_t *p, int type, uint8_t **q);

/// Decode a single typed integer (type byte followed by value) from a BCF
/// byte stream.
/// Wraps: static inline int64_t bcf_dec_typed_int1(const uint8_t *p,
///        uint8_t **q)
int64_t hts_shim_bcf_dec_typed_int1(const uint8_t *p, uint8_t **q);

/// Convert a genotype index back into a pair of allele indices.
/// Wraps: static inline void bcf_gt2alleles(int igt, int *a, int *b)
void hts_shim_bcf_gt2alleles(int igt, int *a, int *b);

/* ── BCF index/iterator macro wrappers ──────────────────────────────────── */

/// Create an iterator for a region specified by tid, beg, end.
/// Wraps: bcf_itr_queryi(idx, tid, beg, end)
hts_itr_t *hts_shim_bcf_itr_queryi(const hts_idx_t *idx, int tid, hts_pos_t beg, hts_pos_t end);

/// Create an iterator for a region specified by a string (e.g. "chr1:1000-2000").
/// Wraps: bcf_itr_querys(idx, hdr, s)
hts_itr_t *hts_shim_bcf_itr_querys(const hts_idx_t *idx, bcf_hdr_t *hdr, const char *s);

/// Read the next record from a BCF iterator.
/// Wraps: bcf_itr_next(htsfp, itr, r)
int hts_shim_bcf_itr_next(htsFile *htsfp, hts_itr_t *itr, bcf1_t *r);

/* ── Synced BCF reader macro/variadic wrappers ──────────────────────────── */

/// Check if reader i has a line at current position.
/// Wraps: bcf_sr_has_line(readers, i)
int hts_shim_bcf_sr_has_line(bcf_srs_t *readers, int i);

/// Get BCF record from reader i (NULL if not present).
/// Wraps: bcf_sr_get_line(readers, i)
bcf1_t *hts_shim_bcf_sr_get_line(bcf_srs_t *readers, int i);

/// Get header from reader i.
/// Wraps: bcf_sr_get_header(readers, i)
bcf_hdr_t *hts_shim_bcf_sr_get_header(bcf_srs_t *readers, int i);

/// Set pairing logic for synced reader.
/// Wraps: bcf_sr_set_opt(readers, BCF_SR_PAIR_LOGIC, logic)
int hts_shim_bcf_sr_set_opt_pair_logic(bcf_srs_t *readers, int logic);

/// Require index for all readers.
/// Wraps: bcf_sr_set_opt(readers, BCF_SR_REQUIRE_IDX)
int hts_shim_bcf_sr_set_opt_require_idx(bcf_srs_t *readers);

/// Allow readers without index.
/// Wraps: bcf_sr_set_opt(readers, BCF_SR_ALLOW_NO_IDX)
int hts_shim_bcf_sr_set_opt_allow_no_idx(bcf_srs_t *readers);

/// Set region overlap mode.
/// Wraps: bcf_sr_set_opt(readers, BCF_SR_REGIONS_OVERLAP, overlap)
int hts_shim_bcf_sr_set_opt_regions_overlap(bcf_srs_t *readers, int overlap);

/// Set target overlap mode.
/// Wraps: bcf_sr_set_opt(readers, BCF_SR_TARGETS_OVERLAP, overlap)
int hts_shim_bcf_sr_set_opt_targets_overlap(bcf_srs_t *readers, int overlap);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_VCF_SHIMS_H */
