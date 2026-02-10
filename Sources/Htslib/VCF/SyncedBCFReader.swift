// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// Reads multiple VCF/BCF files simultaneously, iterating in coordinate order.
///
/// Usage:
/// ```
/// let reader = try SyncedBCFReader()
/// reader.allowNoIndex()
/// try reader.addReader(path: "file1.vcf.gz")
/// try reader.addReader(path: "file2.vcf.gz")
/// while reader.nextLine() > 0 {
///     for i in 0..<reader.nReaders {
///         if reader.hasLine(at: i), var record = reader.getRecord(at: i) {
///             // process record
///         }
///     }
/// }
/// ```
public final class SyncedBCFReader {
    private var pointer: UnsafeMutablePointer<bcf_srs_t>

    /// Create a new synced BCF reader.
    public init() throws {
        guard let ptr = bcf_sr_init() else {
            throw HTSError.outOfMemory
        }
        self.pointer = ptr
    }

    /// Number of readers added.
    public var nReaders: Int {
        Int(pointer.pointee.nreaders)
    }

    // MARK: - Options

    /// Allow readers without an index file.
    @discardableResult
    public func allowNoIndex() -> Int32 {
        hts_shim_bcf_sr_set_opt_allow_no_idx(pointer)
    }

    /// Require an index for all readers.
    @discardableResult
    public func requireIndex() -> Int32 {
        hts_shim_bcf_sr_set_opt_require_idx(pointer)
    }

    /// Set the pairing logic for multi-file reading.
    @discardableResult
    public func setPairLogic(_ logic: Int32) -> Int32 {
        hts_shim_bcf_sr_set_opt_pair_logic(pointer, logic)
    }

    /// Set region overlap mode.
    @discardableResult
    public func setRegionsOverlap(_ overlap: Int32) -> Int32 {
        hts_shim_bcf_sr_set_opt_regions_overlap(pointer, overlap)
    }

    /// Set target overlap mode.
    @discardableResult
    public func setTargetsOverlap(_ overlap: Int32) -> Int32 {
        hts_shim_bcf_sr_set_opt_targets_overlap(pointer, overlap)
    }

    // MARK: - Readers

    /// Add a VCF/BCF file to the synced reader.
    ///
    /// - Parameter path: Path to the VCF/BCF file.
    /// - Throws: ``HTSError/openFailed(path:mode:)`` if the file cannot be opened.
    public func addReader(path: String) throws {
        let ret = path.withCString { bcf_sr_add_reader(pointer, $0) }
        if ret != 1 {
            throw HTSError.openFailed(path: path, mode: "r")
        }
    }

    /// Remove a reader by its 0-based index.
    ///
    /// - Parameter index: The reader index to remove.
    public func removeReader(at index: Int) {
        bcf_sr_remove_reader(pointer, Int32(index))
    }

    // MARK: - Iteration

    /// Advance to the next coordinate. Returns the number of readers with data.
    public func nextLine() -> Int32 {
        bcf_sr_next_line(pointer)
    }

    /// Check whether reader at `index` has a record at the current position.
    public func hasLine(at index: Int) -> Bool {
        hts_shim_bcf_sr_has_line(pointer, Int32(index)) != 0
    }

    /// Get a copy of the VCF record from reader at `index`.
    /// Returns nil if the reader doesn't have a record at the current position.
    public func getRecord(at index: Int) -> VCFRecord? {
        guard let line = hts_shim_bcf_sr_get_line(pointer, Int32(index)) else { return nil }
        guard let copy = bcf_dup(line) else { return nil }
        return VCFRecord(pointer: copy)
    }

    /// Get the header from reader at `index`.
    /// Returns a non-owning header (valid for the lifetime of this reader).
    public func getHeader(at index: Int) -> VCFHeader? {
        guard let hdr = hts_shim_bcf_sr_get_header(pointer, Int32(index)) else { return nil }
        return VCFHeader(pointer: hdr, owned: false)
    }

    // MARK: - Regions and targets

    /// Set regions to iterate over.
    ///
    /// - Parameters:
    ///   - regions: A comma-separated region string or file path.
    ///   - isFile: If `true`, treat `regions` as a path to a file containing regions.
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func setRegions(_ regions: String, isFile: Bool = false) -> Int32 {
        regions.withCString { bcf_sr_set_regions(pointer, $0, isFile ? 1 : 0) }
    }

    /// Set targets to restrict iteration.
    ///
    /// Unlike regions, targets are used for filtering rather than seeking.
    /// - Parameters:
    ///   - targets: A comma-separated target string or file path.
    ///   - isFile: If `true`, treat `targets` as a path to a file containing targets.
    ///   - alleles: Allele matching mode (0 for default).
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func setTargets(_ targets: String, isFile: Bool = false, alleles: Int32 = 0) -> Int32 {
        targets.withCString { bcf_sr_set_targets(pointer, $0, isFile ? 1 : 0, alleles) }
    }

    /// Seek to a specific genomic position.
    ///
    /// - Parameters:
    ///   - contig: The contig name (e.g. `"chr1"`).
    ///   - position: 0-based position on the contig.
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func seek(contig: String, position: Int64) -> Int32 {
        contig.withCString { bcf_sr_seek(pointer, $0, position) }
    }

    // MARK: - Threading

    /// Set the number of decompression threads.
    @discardableResult
    public func setThreads(_ n: Int32) -> Int32 {
        bcf_sr_set_threads(pointer, n)
    }

    deinit {
        bcf_sr_destroy(pointer)
    }
}
