/*
 * htslib_endian_shims.c
 *
 * Non-inline C wrappers for endian conversion inline functions
 * from htslib/hts_endian.h that Swift cannot import directly.
 *
 * Each function delegates to the original inline function.
 */

#include "include/htslib_endian_shims.h"

// ---------------------------------------------------------------------------
// Little-endian to host byte order (unsigned)
// ---------------------------------------------------------------------------

uint8_t hts_shim_le_to_u8(const uint8_t *buf) {
    return le_to_u8(buf);
}

uint16_t hts_shim_le_to_u16(const uint8_t *buf) {
    return le_to_u16(buf);
}

uint32_t hts_shim_le_to_u32(const uint8_t *buf) {
    return le_to_u32(buf);
}

uint64_t hts_shim_le_to_u64(const uint8_t *buf) {
    return le_to_u64(buf);
}

// ---------------------------------------------------------------------------
// Little-endian to host byte order (signed)
// ---------------------------------------------------------------------------

int8_t hts_shim_le_to_i8(const uint8_t *buf) {
    return le_to_i8(buf);
}

int16_t hts_shim_le_to_i16(const uint8_t *buf) {
    return le_to_i16(buf);
}

int32_t hts_shim_le_to_i32(const uint8_t *buf) {
    return le_to_i32(buf);
}

int64_t hts_shim_le_to_i64(const uint8_t *buf) {
    return le_to_i64(buf);
}

// ---------------------------------------------------------------------------
// Little-endian to host byte order (floating point)
// ---------------------------------------------------------------------------

float hts_shim_le_to_float(const uint8_t *buf) {
    return le_to_float(buf);
}

double hts_shim_le_to_double(const uint8_t *buf) {
    return le_to_double(buf);
}

// ---------------------------------------------------------------------------
// Host byte order to little-endian (unsigned)
// ---------------------------------------------------------------------------

void hts_shim_u16_to_le(uint16_t val, uint8_t *buf) {
    u16_to_le(val, buf);
}

void hts_shim_u32_to_le(uint32_t val, uint8_t *buf) {
    u32_to_le(val, buf);
}

void hts_shim_u64_to_le(uint64_t val, uint8_t *buf) {
    u64_to_le(val, buf);
}

// ---------------------------------------------------------------------------
// Host byte order to little-endian (signed)
// ---------------------------------------------------------------------------

void hts_shim_i16_to_le(int16_t val, uint8_t *buf) {
    i16_to_le(val, buf);
}

void hts_shim_i32_to_le(int32_t val, uint8_t *buf) {
    i32_to_le(val, buf);
}

void hts_shim_i64_to_le(int64_t val, uint8_t *buf) {
    i64_to_le(val, buf);
}

// ---------------------------------------------------------------------------
// Host byte order to little-endian (floating point)
// ---------------------------------------------------------------------------

void hts_shim_float_to_le(float val, uint8_t *buf) {
    float_to_le(val, buf);
}

void hts_shim_double_to_le(double val, uint8_t *buf) {
    double_to_le(val, buf);
}
