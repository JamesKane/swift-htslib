import CHtslib
import CHTSlibShims

/// VCF record mutation — INFO, FORMAT, alleles, ID, and filter updates.
extension VCFRecord {
    // MARK: - INFO update

    /// Update or set an integer INFO field.
    ///
    /// - Parameters:
    ///   - key: The INFO field key (e.g. `"DP"`).
    ///   - header: The ``VCFHeader`` for this file.
    ///   - values: The integer values to set. Pass an empty array to remove the field.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateInfoInt32(forKey key: String, header: VCFHeader, values: [Int32]) throws {
        let ret = values.withUnsafeBufferPointer { buf in
            key.withCString { k in
                hts_shim_bcf_update_info_int32(header.pointer, pointer, k, buf.baseAddress, Int32(values.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update or set a floating-point INFO field.
    ///
    /// - Parameters:
    ///   - key: The INFO field key (e.g. `"AF"`).
    ///   - header: The ``VCFHeader`` for this file.
    ///   - values: The float values to set. Pass an empty array to remove the field.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateInfoFloat(forKey key: String, header: VCFHeader, values: [Float]) throws {
        let ret = values.withUnsafeBufferPointer { buf in
            key.withCString { k in
                hts_shim_bcf_update_info_float(header.pointer, pointer, k, buf.baseAddress, Int32(values.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update or set a string INFO field.
    ///
    /// - Parameters:
    ///   - key: The INFO field key.
    ///   - header: The ``VCFHeader`` for this file.
    ///   - value: The string value to set. Pass `nil` to remove the field.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateInfoString(forKey key: String, header: VCFHeader, value: String?) throws {
        let ret: Int32
        if let value = value {
            ret = key.withCString { k in
                value.withCString { v in
                    hts_shim_bcf_update_info_string(header.pointer, pointer, k, v)
                }
            }
        } else {
            ret = key.withCString { k in
                hts_shim_bcf_update_info_string(header.pointer, pointer, k, nil)
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Set or remove an INFO flag.
    ///
    /// - Parameters:
    ///   - key: The INFO flag key.
    ///   - header: The ``VCFHeader`` for this file.
    ///   - set: `true` to set the flag, `false` to remove it.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateInfoFlag(forKey key: String, header: VCFHeader, set: Bool) throws {
        let ret = key.withCString { k in
            hts_shim_bcf_update_info_flag(header.pointer, pointer, k, nil, set ? 1 : 0)
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    // MARK: - FORMAT update

    /// Update or set an integer FORMAT field across all samples.
    ///
    /// The values array should contain `valuesPerSample * nSamples` elements.
    /// - Parameters:
    ///   - key: The FORMAT field key (e.g. `"DP"`).
    ///   - header: The ``VCFHeader`` for this file.
    ///   - values: The integer values (flat array, all samples concatenated).
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateFormatInt32(forKey key: String, header: VCFHeader, values: [Int32]) throws {
        let ret = values.withUnsafeBufferPointer { buf in
            key.withCString { k in
                hts_shim_bcf_update_format_int32(header.pointer, pointer, k, buf.baseAddress, Int32(values.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update or set a floating-point FORMAT field across all samples.
    ///
    /// - Parameters:
    ///   - key: The FORMAT field key (e.g. `"GL"`).
    ///   - header: The ``VCFHeader`` for this file.
    ///   - values: The float values (flat array, all samples concatenated).
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateFormatFloat(forKey key: String, header: VCFHeader, values: [Float]) throws {
        let ret = values.withUnsafeBufferPointer { buf in
            key.withCString { k in
                hts_shim_bcf_update_format_float(header.pointer, pointer, k, buf.baseAddress, Int32(values.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update or set a string FORMAT field across all samples.
    ///
    /// String values for all samples are concatenated with null separators.
    /// - Parameters:
    ///   - key: The FORMAT field key.
    ///   - header: The ``VCFHeader`` for this file.
    ///   - values: An array of strings, one per sample.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateFormatString(forKey key: String, header: VCFHeader, values: [String]) throws {
        // bcf_update_format_char expects a flat char buffer with null-separated values
        let joined = values.joined(separator: "\0")
        let ret = joined.withCString { buf in
            key.withCString { k in
                hts_shim_bcf_update_format_char(header.pointer, pointer, k, buf, Int32(joined.utf8.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update genotypes for all samples.
    ///
    /// The genotypes array should be encoded using BCF genotype encoding
    /// (e.g. via `hts_shim_bcf_gt_phased`/`hts_shim_bcf_gt_unphased`).
    /// - Parameters:
    ///   - header: The ``VCFHeader`` for this file.
    ///   - genotypes: Encoded genotype values (flat array: ploidy * nSamples).
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateGenotypes(header: VCFHeader, genotypes: [Int32]) throws {
        let ret = genotypes.withUnsafeBufferPointer { buf in
            hts_shim_bcf_update_genotypes(header.pointer, pointer, buf.baseAddress, Int32(genotypes.count))
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    // MARK: - Alleles / ID / Filter

    /// Update the alleles (REF and ALT) for this record.
    ///
    /// - Parameters:
    ///   - header: The ``VCFHeader`` for this file.
    ///   - alleles: Array of allele strings. Element 0 is REF, rest are ALT.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateAlleles(header: VCFHeader, alleles: [String]) throws {
        // bcf_update_alleles_str expects comma-separated alleles
        let allelesStr = alleles.joined(separator: ",")
        let ret = allelesStr.withCString { s in
            bcf_update_alleles_str(header.pointer, pointer, s)
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update the variant ID field.
    ///
    /// - Parameters:
    ///   - header: The ``VCFHeader`` for this file.
    ///   - id: The new ID string.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func updateID(header: VCFHeader, id: String) throws {
        let ret = id.withCString { s in
            bcf_update_id(header.pointer, pointer, s)
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Add a filter to this record.
    ///
    /// - Parameters:
    ///   - header: The ``VCFHeader`` for this file.
    ///   - filterID: The numeric filter ID (from ``VCFHeader/headerID(for:name:)``).
    /// - Returns: 1 if the filter was added, 0 if already present.
    @discardableResult
    public mutating func addFilter(header: VCFHeader, filterID: Int32) -> Int32 {
        bcf_add_filter(header.pointer, pointer, filterID)
    }

    /// Remove a filter from this record.
    ///
    /// - Parameters:
    ///   - header: The ``VCFHeader`` for this file.
    ///   - filterID: The numeric filter ID to remove.
    /// - Returns: 1 if the filter was removed, 0 if not present.
    @discardableResult
    public mutating func removeFilter(header: VCFHeader, filterID: Int32) -> Int32 {
        bcf_remove_filter(header.pointer, pointer, filterID, 0)
    }

    /// Check whether this record has a specific filter.
    ///
    /// - Parameters:
    ///   - header: The ``VCFHeader`` for this file.
    ///   - name: The filter name (e.g. `"PASS"`, `"LowQual"`).
    /// - Returns: `true` if the filter is present or if "." and no filters are set.
    public func hasFilter(header: VCFHeader, name: String) -> Bool {
        let ret = name.withCString { s in
            bcf_has_filter(header.pointer, pointer, UnsafeMutablePointer(mutating: s))
        }
        return ret == 1
    }
}
