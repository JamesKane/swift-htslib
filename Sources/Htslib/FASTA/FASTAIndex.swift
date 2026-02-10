// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// Indexed FASTA sequence retrieval.
///
/// `FASTAIndex` loads a FASTA file and its `.fai` index, enabling fast random-access
/// retrieval of subsequences by name and coordinates. This is a move-only type
/// that destroys the index on deinitialization.
public struct FASTAIndex: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: OpaquePointer  // faidx_t*

    /// Open a FASTA file and load (or optionally build) its index.
    ///
    /// - Parameters:
    ///   - path: Path to the FASTA file.
    ///   - buildIndex: If `true`, create the `.fai` index if it doesn't exist.
    /// - Throws: ``HTSError/indexLoadFailed(path:)`` if the index cannot be loaded.
    public init(path: String, buildIndex: Bool = false) throws {
        let flags: Int32 = buildIndex ? 0x01 : 0  // FAI_CREATE
        guard let fai = path.withCString({ fai_load3($0, nil, nil, flags) }) else {
            throw HTSError.indexLoadFailed(path: path)
        }
        self.pointer = fai
    }

    /// The number of sequences in the index.
    public var sequenceCount: Int {
        Int(faidx_nseq(pointer))
    }

    /// Get the name of the sequence at the given index.
    ///
    /// - Parameter index: 0-based sequence index.
    /// - Returns: The sequence name, or `nil` if the index is out of range.
    public func sequenceName(at index: Int) -> String? {
        guard let name = faidx_iseq(pointer, Int32(index)) else { return nil }
        return String(cString: name)
    }

    /// Get the length of a named sequence.
    ///
    /// - Parameter name: The sequence name (e.g. `"chr1"`).
    /// - Returns: The sequence length in bases, or -1 if not found.
    public func sequenceLength(name: String) -> Int64 {
        name.withCString { faidx_seq_len64(pointer, $0) }
    }

    /// Check whether a sequence exists in the index.
    ///
    /// - Parameter name: The sequence name.
    /// - Returns: `true` if the sequence is present.
    public func hasSequence(name: String) -> Bool {
        name.withCString { faidx_has_seq(pointer, $0) } != 0
    }

    /// Fetch a subsequence using a region string.
    ///
    /// - Parameter region: A samtools-style region string (e.g. `"chr1:1000-2000"`).
    /// - Returns: The fetched sequence as a `String`.
    /// - Throws: ``HTSError/regionParseFailed(region:)`` if the region is invalid.
    public func fetch(region: String) throws -> String {
        var len: Int32 = 0
        guard let seq = region.withCString({ fai_fetch(pointer, $0, &len) }) else {
            throw HTSError.regionParseFailed(region: region)
        }
        defer { free(UnsafeMutablePointer(mutating: seq)) }
        return String(cString: seq)
    }

    /// Fetch a subsequence by name and 0-based coordinates.
    ///
    /// - Parameters:
    ///   - sequence: The sequence name (e.g. `"chr1"`).
    ///   - start: 0-based start position (inclusive).
    ///   - end: 0-based end position (inclusive).
    /// - Returns: The fetched sequence as a `String`.
    /// - Throws: ``HTSError/regionParseFailed(region:)`` if the coordinates are invalid.
    public func fetch(sequence: String, start: Int64, end: Int64) throws -> String {
        var len: Int64 = 0
        guard let seq = sequence.withCString({
            faidx_fetch_seq64(pointer, $0, start, end, &len)
        }) else {
            throw HTSError.regionParseFailed(region: "\(sequence):\(start)-\(end)")
        }
        defer { free(UnsafeMutablePointer(mutating: seq)) }
        return String(cString: seq)
    }

    /// Attach a shared thread pool for parallel decompression.
    ///
    /// - Parameters:
    ///   - pool: The ``ThreadPool`` to use.
    ///   - queueSize: Size of the task queue (0 for default).
    public func setThreadPool(_ pool: borrowing ThreadPool, queueSize: Int32 = 0) {
        fai_thread_pool(pointer, pool.pointer, queueSize)
    }

    deinit {
        fai_destroy(pointer)
    }
}
