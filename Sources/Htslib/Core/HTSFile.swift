// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// A handle to an open HTS file (SAM/BAM/CRAM/VCF/BCF).
///
/// `HTSFile` is the primary entry point for opening sequencing data files.
/// It is a move-only type (`~Copyable`) that owns the underlying `htsFile` pointer
/// and closes it automatically on deinitialization.
public struct HTSFile: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<htsFile>

    /// The file system path this handle was opened from.
    public let path: String
    /// The mode string used to open this file (e.g. `"r"`, `"w"`, `"wb"`).
    public let mode: String

    /// Open an HTS file at the given path.
    ///
    /// - Parameters:
    ///   - path: File system path to the file.
    ///   - mode: Open mode (`"r"` for reading, `"w"` for writing, `"wb"` for binary writing, etc.).
    /// - Throws: ``HTSError/openFailed(path:mode:)`` if the file cannot be opened.
    public init(path: String, mode: String) throws {
        guard let fp = hts_open(path, mode) else {
            throw HTSError.openFailed(path: path, mode: mode)
        }
        self.pointer = fp
        self.path = path
        self.mode = mode
    }

    /// The detected file format (e.g. `.bam`, `.vcf`, `.cram`).
    public var format: HTSFileFormat {
        HTSFileFormat(from: pointer.pointee.format.format)
    }

    /// The format category (e.g. `.sequenceData`, `.variantData`).
    public var category: HTSFormatCategory {
        HTSFormatCategory(from: pointer.pointee.format.category)
    }

    /// Whether this file was opened for writing.
    public var isWrite: Bool {
        pointer.pointee.is_write != 0
    }

    /// Set the number of additional threads for this file's I/O.
    ///
    /// - Parameter n: Number of extra threads (0 = single-threaded).
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func setThreads(_ n: Int32) -> Int32 {
        hts_set_threads(pointer, n)
    }

    /// Attach a shared thread pool for this file's I/O.
    ///
    /// - Parameters:
    ///   - pool: The ``ThreadPool`` to use.
    ///   - queueSize: Size of the task queue (0 for default).
    /// - Returns: 0 on success, negative on failure.
    public func setThreadPool(_ pool: borrowing ThreadPool, queueSize: Int32 = 0) -> Int32 {
        var tp = htsThreadPool(pool: pool.pointer, qsize: queueSize)
        return hts_set_thread_pool(pointer, &tp)
    }

    // MARK: - SAM/BAM writing

    /// Write a single alignment record to this file.
    ///
    /// - Parameters:
    ///   - record: The ``BAMRecord`` to write.
    ///   - header: The ``SAMHeader`` for the output file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func write(record: borrowing BAMRecord, header: SAMHeader) throws {
        let ret = sam_write1(pointer, header.pointer, record.pointer)
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Format a single alignment record as a SAM text line.
    ///
    /// - Parameters:
    ///   - record: The ``BAMRecord`` to format.
    ///   - header: The ``SAMHeader`` for the output.
    /// - Returns: The SAM-formatted string, or `nil` on failure.
    public func format(record: borrowing BAMRecord, header: SAMHeader) -> String? {
        var ks = kstring_t(l: 0, m: 0, s: nil)
        let ret = sam_format1(header.pointer, record.pointer, &ks)
        guard ret >= 0, let s = ks.s else {
            free(ks.s)
            return nil
        }
        let result = String(cString: s)
        free(ks.s)
        return result
    }

    // MARK: - VCF/BCF writing

    /// Write a single variant record to this file.
    ///
    /// - Parameters:
    ///   - record: The ``VCFRecord`` to write.
    ///   - header: The ``VCFHeader`` for the output file.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func write(record: borrowing VCFRecord, header: VCFHeader) throws {
        let ret = hts_shim_bcf_write1(pointer, header.pointer, record.pointer)
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    // MARK: - Generic file operations

    /// Set the FASTA reference index file for CRAM decoding/encoding.
    ///
    /// - Parameter path: Path to the `.fai` file.
    /// - Throws: ``HTSError/invalidArgument(message:)`` on failure.
    public func setFaiFilename(_ path: String) throws {
        let ret = path.withCString { hts_set_fai_filename(pointer, $0) }
        if ret < 0 {
            throw HTSError.invalidArgument(message: "Failed to set FAI filename: \(path)")
        }
    }

    /// Check whether the file has a valid EOF marker.
    ///
    /// - Returns: 1 if the EOF marker is present, 0 if absent, negative on error.
    public func checkEOF() -> Int32 {
        hts_check_EOF(pointer)
    }

    /// Flush any buffered data to the file.
    ///
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func flush() throws {
        let ret = hts_flush(pointer)
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    // MARK: - CRAM / format options

    /// Set an integer CRAM option on this file.
    ///
    /// - Parameters:
    ///   - option: The ``CRAMOption`` to set.
    ///   - intValue: The integer value.
    /// - Throws: ``HTSError/invalidArgument(message:)`` on failure.
    public func setOption(_ option: CRAMOption, intValue: Int32) throws {
        let ret = hts_shim_set_opt_int(pointer, option.rawValue, intValue)
        if ret < 0 {
            throw HTSError.invalidArgument(message: "Failed to set CRAM option")
        }
    }

    /// Set a string CRAM option on this file.
    ///
    /// - Parameters:
    ///   - option: The ``CRAMOption`` to set (typically `.reference`).
    ///   - stringValue: The string value (e.g. path to reference FASTA).
    /// - Throws: ``HTSError/invalidArgument(message:)`` on failure.
    public func setOption(_ option: CRAMOption, stringValue: String) throws {
        let ret = stringValue.withCString { hts_shim_set_opt_str(pointer, option.rawValue, $0) }
        if ret < 0 {
            throw HTSError.invalidArgument(message: "Failed to set CRAM option")
        }
    }

    /// Set a compression profile preset on this file.
    ///
    /// - Parameter profile: The ``CompressionProfile`` to use.
    /// - Throws: ``HTSError/invalidArgument(message:)`` on failure.
    public func setCompressionProfile(_ profile: CompressionProfile) throws {
        let ret = hts_shim_set_opt_int(pointer, HTS_OPT_PROFILE, Int32(profile.rawValue.rawValue))
        if ret < 0 {
            throw HTSError.invalidArgument(message: "Failed to set compression profile")
        }
    }

    /// Set a filter expression for record filtering.
    ///
    /// - Parameter expression: The filter expression string.
    /// - Throws: ``HTSError/invalidArgument(message:)`` on failure.
    public func setFilterExpression(_ expression: String) throws {
        let ret = expression.withCString { hts_set_filter_expression(pointer, $0) }
        if ret < 0 {
            throw HTSError.invalidArgument(message: "Failed to set filter expression: \(expression)")
        }
    }

    // MARK: - SAM/BAM factory methods

    /// Read the SAM/BAM/CRAM header from this file.
    ///
    /// - Returns: The ``SAMHeader`` for this file.
    /// - Throws: ``HTSError/headerReadFailed`` if the header cannot be read.
    public func samHeader() throws -> SAMHeader {
        try SAMHeader(from: self)
    }

    /// Create a sequential iterator over all alignment records in this file.
    ///
    /// - Parameter header: The ``SAMHeader`` obtained from ``samHeader()``.
    /// - Returns: A ``SAMRecordIterator`` yielding all records.
    public func samIterator(header: SAMHeader) -> SAMRecordIterator {
        SAMRecordIterator(file: pointer, header: header.pointer)
    }

    /// Create an indexed iterator over alignment records overlapping a region.
    ///
    /// - Parameters:
    ///   - header: The ``SAMHeader`` obtained from ``samHeader()``.
    ///   - index: The ``HTSIndex`` for this file.
    ///   - region: A region string (e.g. `"chr1:1000-2000"`).
    /// - Returns: A ``SAMQueryIterator`` yielding overlapping records.
    /// - Throws: ``HTSError/seekFailed`` if the query cannot be created.
    public func samQueryIterator(header: SAMHeader, index: borrowing HTSIndex, region: String) throws -> SAMQueryIterator {
        guard let itr = region.withCString({ sam_itr_querys(index.pointer, header.pointer, $0) }) else {
            throw HTSError.seekFailed
        }
        return SAMQueryIterator(file: pointer, iterator: itr)
    }

    // MARK: - VCF/BCF factory methods

    /// Read the VCF/BCF header from this file.
    ///
    /// - Returns: The ``VCFHeader`` for this file.
    /// - Throws: ``HTSError/headerReadFailed`` if the header cannot be read.
    public func vcfHeader() throws -> VCFHeader {
        try VCFHeader(from: self)
    }

    /// Create a sequential iterator over all variant records in this file.
    ///
    /// - Parameter header: The ``VCFHeader`` obtained from ``vcfHeader()``.
    /// - Returns: A ``VCFRecordIterator`` yielding all records.
    public func vcfIterator(header: VCFHeader) -> VCFRecordIterator {
        VCFRecordIterator(file: pointer, header: header.pointer)
    }

    deinit {
        hts_close(pointer)
    }

    // Internal access for other types
    @usableFromInline
    var rawPointer: UnsafeMutablePointer<htsFile> { pointer }
}
