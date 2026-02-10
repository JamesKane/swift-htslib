/*
 * htslib_sam_shims.h
 *
 * Non-inline C wrappers for SAM/BAM macros and inline functions
 * from htslib/sam.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_SAM_SHIMS_H
#define HTSLIB_SAM_SHIMS_H

#include <htslib/hts.h>
#include <htslib/sam.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// CIGAR macros
// ---------------------------------------------------------------------------

/// Extract the CIGAR operation from a CIGAR field element.
uint32_t hts_shim_bam_cigar_op(uint32_t c);

/// Extract the operation length from a CIGAR field element.
uint32_t hts_shim_bam_cigar_oplen(uint32_t c);

/// Return the character representation of a CIGAR operation.
char hts_shim_bam_cigar_opchr(uint32_t c);

/// Generate a CIGAR field element from a length and operation.
uint32_t hts_shim_bam_cigar_gen(uint32_t l, uint32_t o);

/// Return a bit flag indicating whether a CIGAR operation consumes query/reference.
uint32_t hts_shim_bam_cigar_type(uint32_t o);

// ---------------------------------------------------------------------------
// Alignment record flag queries
// ---------------------------------------------------------------------------

/// Return non-zero if the read is mapped to the reverse strand.
int hts_shim_bam_is_rev(const bam1_t *b);

/// Return non-zero if the mate is mapped to the reverse strand.
int hts_shim_bam_is_mrev(const bam1_t *b);

// ---------------------------------------------------------------------------
// Alignment record data access
// ---------------------------------------------------------------------------

/// Return a pointer to the query name.
char *hts_shim_bam_get_qname(const bam1_t *b);

/// Return a pointer to the CIGAR array.
uint32_t *hts_shim_bam_get_cigar(const bam1_t *b);

/// Return a pointer to the query sequence (4-bit encoded).
uint8_t *hts_shim_bam_get_seq(const bam1_t *b);

/// Return a pointer to the base quality array.
uint8_t *hts_shim_bam_get_qual(const bam1_t *b);

/// Return a pointer to the auxiliary data.
uint8_t *hts_shim_bam_get_aux(const bam1_t *b);

/// Return the length of the auxiliary data.
int hts_shim_bam_get_l_aux(const bam1_t *b);

// ---------------------------------------------------------------------------
// Sequence base access
// ---------------------------------------------------------------------------

/// Retrieve a single 4-bit encoded base from a query sequence.
uint8_t hts_shim_bam_seqi(const uint8_t *s, int i);

/// Set a single 4-bit encoded base in a query sequence.
void hts_shim_bam_set_seqi(uint8_t *s, int i, uint8_t b);

// ---------------------------------------------------------------------------
// File open / close / iterator macros
// ---------------------------------------------------------------------------

/// Open a SAM/BAM/CRAM file (wraps sam_open macro).
samFile *hts_shim_sam_open(const char *fn, const char *mode);

/// Close a SAM/BAM/CRAM file (wraps sam_close macro).
int hts_shim_sam_close(htsFile *fp);

/// Destroy a SAM iterator (wraps sam_itr_destroy macro).
void hts_shim_sam_itr_destroy(hts_itr_t *iter);

// ---------------------------------------------------------------------------
// Inline function wrappers
// ---------------------------------------------------------------------------

/// Read the next record from an iterator.
int hts_shim_sam_itr_next(htsFile *htsfp, hts_itr_t *itr, bam1_t *r);

/// Set the memory policy on an alignment record.
void hts_shim_bam_set_mempolicy(bam1_t *b, uint32_t policy);

/// Get the memory policy on an alignment record.
uint32_t hts_shim_bam_get_mempolicy(bam1_t *b);

/// Return the 2-character tag for an auxiliary field.
const char *hts_shim_bam_aux_tag(const uint8_t *s);

/// Return the type character for an auxiliary field.
char hts_shim_bam_aux_type(const uint8_t *s);

/// Format an auxiliary field as a SAM string into a kstring.
int hts_shim_bam_aux_get_str(const bam1_t *b, const char tag[2], kstring_t *s);

/// Look up a reference sequence by name and return its tid.
int hts_shim_bam_name2id(sam_hdr_t *h, const char *ref);

/// Allocate and return an empty SAM header (deprecated compatibility wrapper).
sam_hdr_t *hts_shim_bam_hdr_init(void);

/// Destroy a SAM header (deprecated compatibility wrapper).
void hts_shim_bam_hdr_destroy(sam_hdr_t *h);

/// Duplicate a SAM header (deprecated compatibility wrapper).
sam_hdr_t *hts_shim_bam_hdr_dup(const sam_hdr_t *h0);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_SAM_SHIMS_H */
