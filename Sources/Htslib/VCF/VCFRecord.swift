// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// A single variant record from a VCF/BCF file.
///
/// `VCFRecord` is a move-only type (`~Copyable`) that owns the underlying `bcf1_t`
/// allocation and frees it on deinitialization. Call ``unpack(_:)`` before accessing
/// decoded fields like ``id``, ``alleles``, or ``filterIDs``.
public struct VCFRecord: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<bcf1_t>

    /// Allocate an empty VCF record.
    ///
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
    public init() throws {
        guard let v = bcf_init() else {
            throw HTSError.outOfMemory
        }
        self.pointer = v
    }

    internal init(pointer: UnsafeMutablePointer<bcf1_t>) {
        self.pointer = pointer
    }

    /// Unpack (decode) record fields from the binary representation.
    ///
    /// Must be called before accessing decoded fields. Higher unpack levels
    /// include all lower levels.
    ///
    /// - Parameter level: The level of unpacking to perform (default: `.all`).
    /// - Throws: ``HTSError/readFailed(code:)`` if unpacking fails.
    public mutating func unpack(_ level: UnpackLevel = .all) throws {
        let ret = bcf_unpack(pointer, level.rawValue)
        if ret < 0 { throw HTSError.readFailed(code: ret) }
    }

    /// Controls how much of a BCF record is decoded by ``unpack(_:)``.
    public enum UnpackLevel: Int32, Sendable {
        /// Unpack up through the ID field.
        case str = 1     // BCF_UN_STR
        /// Unpack up through the FILTER field.
        case flt = 2     // BCF_UN_FLT
        /// Unpack up through the INFO field.
        case info = 4    // BCF_UN_INFO
        /// Unpack shared and per-sample FORMAT fields.
        case fmt = 8     // BCF_UN_SHR | BCF_UN_FMT
        /// Unpack all fields.
        case all = 15    // BCF_UN_ALL
    }

    // MARK: - Core fields

    /// 0-based position on the reference contig.
    public var position: Int64 { pointer.pointee.pos }
    /// Reference contig ID (index into the header's contig dictionary).
    public var contigID: Int32 { pointer.pointee.rid }
    /// Variant quality score (Phred-scaled), or `Float.nan` if missing.
    public var quality: Float { pointer.pointee.qual }
    /// Number of alleles (REF + ALT).
    public var nAlleles: Int { Int(pointer.pointee.n_allele) }
    /// Number of INFO fields.
    public var nInfo: Int { Int(pointer.pointee.n_info) }
    /// Number of FORMAT fields.
    public var nFormat: Int { Int(pointer.pointee.n_fmt) }
    /// Number of samples.
    public var nSamples: Int { Int(pointer.pointee.n_sample) }

    /// Length of the reference allele in bases.
    public var referenceLength: Int64 { pointer.pointee.rlen }

    /// The variant ID string (requires ``unpack(_:)`` >= `.str`).
    public var id: String? {
        guard let s = pointer.pointee.d.id else { return nil }
        return String(cString: s)
    }

    /// The alleles array — element 0 is REF, the rest are ALT (requires ``unpack(_:)`` >= `.str`).
    public var alleles: [String] {
        let n = Int(pointer.pointee.n_allele)
        guard n > 0, let a = pointer.pointee.d.allele else { return [] }
        return (0..<n).compactMap { i in
            guard let s = a[i] else { return nil }
            return String(cString: s)
        }
    }

    /// Numeric FILTER IDs (requires ``unpack(_:)`` >= `.flt`).
    public var filterIDs: [Int32] {
        let n = Int(pointer.pointee.d.n_flt)
        guard n > 0, let flt = pointer.pointee.d.flt else { return [] }
        return (0..<n).map { flt[$0] }
    }

    /// Resolve FILTER IDs to their string names using the header.
    ///
    /// - Parameter header: The ``VCFHeader`` for this file.
    /// - Returns: An array of filter name strings.
    public func filterNames(header: VCFHeader) -> [String] {
        filterIDs.compactMap { id in
            guard let name = hts_shim_bcf_hdr_int2id(header.pointer, Int32(BCF_DT_ID), Int32(id)) else { return nil }
            return String(cString: name)
        }
    }

    /// The variant type as a ``VariantType`` option set (SNP, indel, etc.).
    public var variantType: VariantType {
        VariantType(rawValue: bcf_get_variant_types(pointer))
    }

    // MARK: - Mutation

    /// Clear all fields and reset this record for reuse.
    public mutating func clear() {
        bcf_clear(pointer)
    }

    /// Set the 0-based position on the reference contig.
    public mutating func setPosition(_ pos: Int64) {
        pointer.pointee.pos = pos
    }

    /// Set the reference contig ID.
    public mutating func setContigID(_ rid: Int32) {
        pointer.pointee.rid = rid
    }

    /// Set the variant quality score (Phred-scaled).
    public mutating func setQuality(_ qual: Float) {
        pointer.pointee.qual = qual
    }

    /// Set the alleles from a comma-separated string (e.g. `"A,T"` or `"ACG,A,ACGT"`).
    ///
    /// - Parameters:
    ///   - allelesStr: Comma-separated allele string (REF first, then ALTs).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func setAlleles(_ allelesStr: String, header: VCFHeader) throws {
        let ret = allelesStr.withCString { ptr in
            bcf_update_alleles_str(header.pointer, pointer, ptr)
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Set the genotype (GT) FORMAT field for all samples.
    ///
    /// Each element should be encoded using ``bcfGenotypeUnphased(_:)``
    /// or ``bcfGenotypePhased(_:)``.
    ///
    /// - Parameters:
    ///   - genotypes: Encoded genotype values (ploidy × nSamples elements).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func setGenotypes(_ genotypes: [Int32], header: VCFHeader) throws {
        var gts = genotypes
        let ret = gts.withUnsafeMutableBufferPointer { buf in
            hts_shim_bcf_update_genotypes(header.pointer, pointer, buf.baseAddress, Int32(buf.count))
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Set an integer FORMAT field for all samples.
    ///
    /// - Parameters:
    ///   - tag: The FORMAT tag name (e.g. `"GQ"`, `"DP"`, `"AD"`).
    ///   - values: Integer values (nValues × nSamples elements).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func setFormatInt32(tag: String, values: [Int32], header: VCFHeader) throws {
        var vals = values
        let ret = tag.withCString { key in
            vals.withUnsafeMutableBufferPointer { buf in
                hts_shim_bcf_update_format_int32(header.pointer, pointer, key, buf.baseAddress, Int32(buf.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Set a float FORMAT field for all samples.
    ///
    /// - Parameters:
    ///   - tag: The FORMAT tag name (e.g. `"GL"`).
    ///   - values: Float values (nValues × nSamples elements).
    ///   - header: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func setFormatFloat(tag: String, values: [Float], header: VCFHeader) throws {
        var vals = values
        let ret = tag.withCString { key in
            vals.withUnsafeMutableBufferPointer { buf in
                hts_shim_bcf_update_format_float(header.pointer, pointer, key, buf.baseAddress, Int32(buf.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Set an integer INFO field.
    ///
    /// - Parameters:
    ///   - tag: The INFO tag name (e.g. `"DP"`).
    ///   - values: Integer values.
    ///   - header: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func setInfoInt32(tag: String, values: [Int32], header: VCFHeader) throws {
        var vals = values
        let ret = tag.withCString { key in
            vals.withUnsafeMutableBufferPointer { buf in
                hts_shim_bcf_update_info_int32(header.pointer, pointer, key, buf.baseAddress, Int32(buf.count))
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Set a string INFO field.
    ///
    /// - Parameters:
    ///   - tag: The INFO tag name.
    ///   - value: The string value.
    ///   - header: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public mutating func setInfoString(tag: String, value: String, header: VCFHeader) throws {
        let ret = tag.withCString { key in
            value.withCString { val in
                hts_shim_bcf_update_info_string(header.pointer, pointer, key, val)
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    // MARK: - Genotype encoding helpers

    /// Encode an unphased genotype allele index for use with ``setGenotypes(_:header:)``.
    ///
    /// - Parameter alleleIndex: 0-based allele index (0 = REF, 1 = first ALT, etc.).
    /// - Returns: Encoded genotype value.
    public static func bcfGenotypeUnphased(_ alleleIndex: Int32) -> Int32 {
        hts_shim_bcf_gt_unphased(alleleIndex)
    }

    /// Encode a phased genotype allele index for use with ``setGenotypes(_:header:)``.
    ///
    /// - Parameter alleleIndex: 0-based allele index.
    /// - Returns: Encoded genotype value.
    public static func bcfGenotypePhased(_ alleleIndex: Int32) -> Int32 {
        hts_shim_bcf_gt_phased(alleleIndex)
    }

    /// The encoded value for a missing genotype allele.
    public static var bcfGenotypeMissing: Int32 {
        hts_shim_bcf_gt_missing()
    }

    // MARK: - Copy / duplicate

    /// Create an independent copy of this record by copying into a new allocation.
    ///
    /// - Returns: A new ``VCFRecord`` that is a deep copy of this one.
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
    public borrowing func copy() throws -> VCFRecord {
        guard let dst = bcf_init() else { throw HTSError.outOfMemory }
        guard bcf_copy(dst, pointer) != nil else {
            bcf_destroy(dst)
            throw HTSError.outOfMemory
        }
        return VCFRecord(pointer: dst)
    }

    /// Duplicate this record (allocate + copy in one step).
    ///
    /// - Returns: A new ``VCFRecord`` that is a deep copy of this one.
    /// - Throws: ``HTSError/outOfMemory`` if duplication fails.
    public borrowing func duplicate() throws -> VCFRecord {
        guard let dup = bcf_dup(pointer) else {
            throw HTSError.outOfMemory
        }
        return VCFRecord(pointer: dup)
    }

    deinit {
        bcf_destroy(pointer)
    }
}
