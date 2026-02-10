/*
 * htslib_endian_shims.h
 *
 * Non-inline C wrappers for endian conversion inline functions
 * from htslib/hts_endian.h that Swift cannot import directly.
 *
 * All wrapper functions use the hts_shim_ prefix.
 */

#ifndef HTSLIB_ENDIAN_SHIMS_H
#define HTSLIB_ENDIAN_SHIMS_H

#include <htslib/hts_endian.h>

#ifdef __cplusplus
extern "C" {
#endif

// ---------------------------------------------------------------------------
// Little-endian to host byte order (unsigned)
// ---------------------------------------------------------------------------

/// Get a uint8_t value from a little-endian byte array.
uint8_t hts_shim_le_to_u8(const uint8_t *buf);

/// Get a uint16_t value from a little-endian byte array.
uint16_t hts_shim_le_to_u16(const uint8_t *buf);

/// Get a uint32_t value from a little-endian byte array.
uint32_t hts_shim_le_to_u32(const uint8_t *buf);

/// Get a uint64_t value from a little-endian byte array.
uint64_t hts_shim_le_to_u64(const uint8_t *buf);

// ---------------------------------------------------------------------------
// Little-endian to host byte order (signed)
// ---------------------------------------------------------------------------

/// Get an int8_t value from a little-endian byte array.
int8_t hts_shim_le_to_i8(const uint8_t *buf);

/// Get an int16_t value from a little-endian byte array.
int16_t hts_shim_le_to_i16(const uint8_t *buf);

/// Get an int32_t value from a little-endian byte array.
int32_t hts_shim_le_to_i32(const uint8_t *buf);

/// Get an int64_t value from a little-endian byte array.
int64_t hts_shim_le_to_i64(const uint8_t *buf);

// ---------------------------------------------------------------------------
// Little-endian to host byte order (floating point)
// ---------------------------------------------------------------------------

/// Get a float value from a little-endian byte array.
float hts_shim_le_to_float(const uint8_t *buf);

/// Get a double value from a little-endian byte array.
double hts_shim_le_to_double(const uint8_t *buf);

// ---------------------------------------------------------------------------
// Host byte order to little-endian (unsigned)
// ---------------------------------------------------------------------------

/// Store a uint16_t value in little-endian byte order.
void hts_shim_u16_to_le(uint16_t val, uint8_t *buf);

/// Store a uint32_t value in little-endian byte order.
void hts_shim_u32_to_le(uint32_t val, uint8_t *buf);

/// Store a uint64_t value in little-endian byte order.
void hts_shim_u64_to_le(uint64_t val, uint8_t *buf);

// ---------------------------------------------------------------------------
// Host byte order to little-endian (signed)
// ---------------------------------------------------------------------------

/// Store an int16_t value in little-endian byte order.
void hts_shim_i16_to_le(int16_t val, uint8_t *buf);

/// Store an int32_t value in little-endian byte order.
void hts_shim_i32_to_le(int32_t val, uint8_t *buf);

/// Store an int64_t value in little-endian byte order.
void hts_shim_i64_to_le(int64_t val, uint8_t *buf);

// ---------------------------------------------------------------------------
// Host byte order to little-endian (floating point)
// ---------------------------------------------------------------------------

/// Store a float value in little-endian byte order.
void hts_shim_float_to_le(float val, uint8_t *buf);

/// Store a double value in little-endian byte order.
void hts_shim_double_to_le(double val, uint8_t *buf);

#ifdef __cplusplus
}
#endif

#endif /* HTSLIB_ENDIAN_SHIMS_H */
