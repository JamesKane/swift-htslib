// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// Typed access to VCF INFO fields.
extension VCFRecord {
    /// Get integer values from an INFO field.
    ///
    /// - Parameters:
    ///   - key: The INFO field key (e.g. `"DP"`, `"AC"`).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: An array of `Int32` values, or `nil` if the field is absent.
    public func infoInt32(forKey key: String, header: VCFHeader) -> [Int32]? {
        var dst: UnsafeMutablePointer<Int32>? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_info_int32(header.pointer, pointer, k, &dst, &ndst)
        }
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }
        return Array(UnsafeBufferPointer(start: buf, count: Int(ret)))
    }

    /// Get floating-point values from an INFO field.
    ///
    /// - Parameters:
    ///   - key: The INFO field key (e.g. `"AF"`).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: An array of `Float` values, or `nil` if the field is absent.
    public func infoFloat(forKey key: String, header: VCFHeader) -> [Float]? {
        var dst: UnsafeMutablePointer<Float>? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_info_float(header.pointer, pointer, k, &dst, &ndst)
        }
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }
        return Array(UnsafeBufferPointer(start: buf, count: Int(ret)))
    }

    /// Get a string value from an INFO field.
    ///
    /// - Parameters:
    ///   - key: The INFO field key (e.g. `"DB"`).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: The string value, or `nil` if the field is absent.
    public func infoString(forKey key: String, header: VCFHeader) -> String? {
        var dst: UnsafeMutablePointer<UInt8>? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_info_string(header.pointer, pointer, k, &dst, &ndst)
        }
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }
        return String(cString: buf)
    }

    /// Check whether an INFO flag is set.
    ///
    /// - Parameters:
    ///   - key: The INFO flag key (e.g. `"DB"`).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: `true` if the flag is present.
    public func infoFlag(forKey key: String, header: VCFHeader) -> Bool {
        var dst: UnsafeMutableRawPointer? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_info_flag(header.pointer, pointer, k, &dst, &ndst)
        }
        if let d = dst { free(d) }
        return ret == 1
    }
}
