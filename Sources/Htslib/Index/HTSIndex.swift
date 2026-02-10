// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// A generic HTS index (BAI, CSI, or TBI) for indexed random access.
///
/// Load an index alongside a BAM/CRAM/VCF file to enable region queries.
/// This is a move-only type that destroys the index on deinitialization.
public struct HTSIndex: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: OpaquePointer  // hts_idx_t*

    /// Load an index for the given file.
    ///
    /// - Parameters:
    ///   - path: Path to the data file (the index is located automatically).
    ///   - format: The expected index format, or `.auto` to auto-detect.
    /// - Throws: ``HTSError/indexLoadFailed(path:)`` if the index cannot be loaded.
    public init(path: String, format: IndexFormat = .auto) throws {
        guard let idx = path.withCString({ hts_idx_load3($0, nil, format.rawValue, 0) }) else {
            throw HTSError.indexLoadFailed(path: path)
        }
        self.pointer = idx
    }

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    /// The index file format.
    public enum IndexFormat: Int32, Sendable {
        /// Auto-detect the index format.
        case auto = 0
        /// BAM index (.bai).
        case bai = 1
        /// Coordinate-sorted index (.csi).
        case csi = 2
        /// Tabix index (.tbi).
        case tbi = 3
    }

    /// The number of reference sequences in the index.
    public func nSequences() -> Int32 {
        hts_idx_nseq(pointer)
    }

    /// Build an index for a SAM/BAM/CRAM file.
    ///
    /// - Parameters:
    ///   - path: Path to the data file.
    ///   - minShift: Minimum bit-shift for CSI indices (0 for BAI default).
    ///   - nThreads: Number of threads for building (0 for single-threaded).
    /// - Throws: ``HTSError/indexBuildFailed(path:code:)`` on failure.
    public static func build(path: String, minShift: Int32 = 0, nThreads: Int32 = 0) throws {
        let ret = path.withCString { sam_index_build3($0, nil, minShift, nThreads) }
        if ret < 0 {
            throw HTSError.indexBuildFailed(path: path, code: ret)
        }
    }

    /// Build an index for a VCF/BCF file.
    ///
    /// - Parameters:
    ///   - path: Path to the VCF/BCF file.
    ///   - minShift: Minimum bit-shift for CSI indices (0 for default TBI).
    ///   - nThreads: Number of threads for building (0 for single-threaded).
    /// - Throws: ``HTSError/indexBuildFailed(path:code:)`` on failure.
    public static func buildVCF(path: String, minShift: Int32 = 0, nThreads: Int32 = 0) throws {
        let ret = path.withCString { bcf_index_build3($0, nil, minShift, nThreads) }
        if ret < 0 {
            throw HTSError.indexBuildFailed(path: path, code: ret)
        }
    }

    deinit {
        hts_idx_destroy(pointer)
    }
}
