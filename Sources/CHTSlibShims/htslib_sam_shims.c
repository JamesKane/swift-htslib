/*
 * htslib_sam_shims.c
 *
 * Non-inline C wrappers for SAM/BAM macros and inline functions
 * from htslib/sam.h that Swift cannot import directly.
 *
 * Each function delegates to the original macro or inline function.
 */

#include "include/htslib_sam_shims.h"

// ---------------------------------------------------------------------------
// CIGAR macros
// ---------------------------------------------------------------------------

uint32_t hts_shim_bam_cigar_op(uint32_t c) {
    return bam_cigar_op(c);
}

uint32_t hts_shim_bam_cigar_oplen(uint32_t c) {
    return bam_cigar_oplen(c);
}

char hts_shim_bam_cigar_opchr(uint32_t c) {
    return bam_cigar_opchr(c);
}

uint32_t hts_shim_bam_cigar_gen(uint32_t l, uint32_t o) {
    return bam_cigar_gen(l, o);
}

uint32_t hts_shim_bam_cigar_type(uint32_t o) {
    return bam_cigar_type(o);
}

// ---------------------------------------------------------------------------
// Alignment record flag queries
// ---------------------------------------------------------------------------

int hts_shim_bam_is_rev(const bam1_t *b) {
    return bam_is_rev(b);
}

int hts_shim_bam_is_mrev(const bam1_t *b) {
    return bam_is_mrev(b);
}

// ---------------------------------------------------------------------------
// Alignment record data access
// ---------------------------------------------------------------------------

char *hts_shim_bam_get_qname(const bam1_t *b) {
    return bam_get_qname(b);
}

uint32_t *hts_shim_bam_get_cigar(const bam1_t *b) {
    return bam_get_cigar(b);
}

uint8_t *hts_shim_bam_get_seq(const bam1_t *b) {
    return bam_get_seq(b);
}

uint8_t *hts_shim_bam_get_qual(const bam1_t *b) {
    return bam_get_qual(b);
}

uint8_t *hts_shim_bam_get_aux(const bam1_t *b) {
    return bam_get_aux(b);
}

int hts_shim_bam_get_l_aux(const bam1_t *b) {
    return bam_get_l_aux(b);
}

// ---------------------------------------------------------------------------
// Sequence base access
// ---------------------------------------------------------------------------

uint8_t hts_shim_bam_seqi(const uint8_t *s, int i) {
    return bam_seqi(s, i);
}

void hts_shim_bam_set_seqi(uint8_t *s, int i, uint8_t b) {
    bam_set_seqi(s, i, b);
}

// ---------------------------------------------------------------------------
// File open / close / iterator macros
// ---------------------------------------------------------------------------

samFile *hts_shim_sam_open(const char *fn, const char *mode) {
    return sam_open(fn, mode);
}

int hts_shim_sam_close(htsFile *fp) {
    return sam_close(fp);
}

void hts_shim_sam_itr_destroy(hts_itr_t *iter) {
    sam_itr_destroy(iter);
}

// ---------------------------------------------------------------------------
// Inline function wrappers
// ---------------------------------------------------------------------------

int hts_shim_sam_itr_next(htsFile *htsfp, hts_itr_t *itr, bam1_t *r) {
    return sam_itr_next(htsfp, itr, r);
}

void hts_shim_bam_set_mempolicy(bam1_t *b, uint32_t policy) {
    bam_set_mempolicy(b, policy);
}

uint32_t hts_shim_bam_get_mempolicy(bam1_t *b) {
    return bam_get_mempolicy(b);
}

const char *hts_shim_bam_aux_tag(const uint8_t *s) {
    return bam_aux_tag(s);
}

char hts_shim_bam_aux_type(const uint8_t *s) {
    return bam_aux_type(s);
}

int hts_shim_bam_aux_get_str(const bam1_t *b, const char tag[2], kstring_t *s) {
    return bam_aux_get_str(b, tag, s);
}

int hts_shim_bam_name2id(sam_hdr_t *h, const char *ref) {
    return bam_name2id(h, ref);
}

sam_hdr_t *hts_shim_bam_hdr_init(void) {
    return bam_hdr_init();
}

void hts_shim_bam_hdr_destroy(sam_hdr_t *h) {
    bam_hdr_destroy(h);
}

sam_hdr_t *hts_shim_bam_hdr_dup(const sam_hdr_t *h0) {
    return bam_hdr_dup(h0);
}
