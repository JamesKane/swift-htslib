import CHtslib
import CHTSlibShims

/// Typed access to VCF FORMAT fields (per-sample data).
extension VCFRecord {
    /// Get integer values from a FORMAT field across all samples.
    ///
    /// The returned array is flattened: values for sample 0 come first, then sample 1, etc.
    /// Each sample has `ret / nSamples` values.
    ///
    /// - Parameters:
    ///   - key: The FORMAT field key (e.g. `"DP"`, `"GQ"`).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: A flat array of `Int32` values, or `nil` if the field is absent.
    public func formatInt32(forKey key: String, header: VCFHeader) -> [Int32]? {
        var dst: UnsafeMutablePointer<Int32>? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_format_int32(header.pointer, pointer, k, &dst, &ndst)
        }
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }
        return Array(UnsafeBufferPointer(start: buf, count: Int(ret)))
    }

    /// Get floating-point values from a FORMAT field across all samples.
    ///
    /// - Parameters:
    ///   - key: The FORMAT field key (e.g. `"GL"`).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: A flat array of `Float` values, or `nil` if the field is absent.
    public func formatFloat(forKey key: String, header: VCFHeader) -> [Float]? {
        var dst: UnsafeMutablePointer<Float>? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_format_float(header.pointer, pointer, k, &dst, &ndst)
        }
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }
        return Array(UnsafeBufferPointer(start: buf, count: Int(ret)))
    }

    /// Get string values from a FORMAT field, one per sample.
    ///
    /// - Parameters:
    ///   - key: The FORMAT field key.
    ///   - header: The ``VCFHeader`` for this file.
    /// - Returns: An array of strings (one per sample), or `nil` if the field is absent.
    public func formatString(forKey key: String, header: VCFHeader) -> [String]? {
        var dst: UnsafeMutablePointer<UInt8>? = nil
        var ndst: Int32 = 0
        let ret = key.withCString { k in
            hts_shim_bcf_get_format_char(header.pointer, pointer, k, &dst, &ndst)
        }
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }
        let n = nSamples
        guard n > 0 else { return nil }
        let perSample = Int(ret) / n
        return (0..<n).map { i in
            let start = buf.advanced(by: i * perSample)
            return String(cString: start)
        }
    }

    /// Decode genotypes for all samples.
    ///
    /// - Parameter header: The ``VCFHeader`` for this file.
    /// - Returns: An array of ``Genotype`` values (one per sample), or `nil` if GT is absent.
    public func genotypes(header: VCFHeader) -> [Genotype]? {
        var dst: UnsafeMutablePointer<Int32>? = nil
        var ndst: Int32 = 0
        let ret = hts_shim_bcf_get_genotypes(header.pointer, pointer, &dst, &ndst)
        guard ret > 0, let buf = dst else { return nil }
        defer { free(buf) }

        let n = nSamples
        guard n > 0 else { return nil }
        let ploidy = Int(ret) / n

        return (0..<n).map { i in
            let sampleGT = buf.advanced(by: i * ploidy)
            return Genotype.decode(from: sampleGT, ploidy: ploidy)
        }
    }
}
