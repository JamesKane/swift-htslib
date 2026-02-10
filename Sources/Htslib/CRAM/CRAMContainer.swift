// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// A CRAM container for low-level CRAM file access.
///
/// CRAM containers hold slices of alignment records. Most users should access
/// CRAM data through the format-agnostic ``HTSFile``/``SAMIterator`` layer.
/// This type is for advanced users building CRAM-specific tools.
///
/// All CRAM types (`cram_fd`, `cram_container`, `cram_block`) are opaque
/// in htslib and are represented as `OpaquePointer` in Swift.
public struct CRAMContainer: ~Copyable, @unchecked Sendable {
    nonisolated(unsafe) var pointer: OpaquePointer  // cram_container*

    /// Create a new empty CRAM container.
    ///
    /// - Parameters:
    ///   - nRecords: Expected number of records per container.
    ///   - nSlices: Expected number of slices per container.
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
    public init(nRecords: Int32, nSlices: Int32) throws {
        guard let ptr = cram_new_container(nRecords, nSlices) else {
            throw HTSError.outOfMemory
        }
        self.pointer = ptr
    }

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    /// The length of the container in bytes.
    public var length: Int32 {
        cram_container_get_length(pointer)
    }

    /// The number of blocks in the container.
    public var numBlocks: Int32 {
        cram_container_get_num_blocks(pointer)
    }

    /// The number of alignment records in the container.
    public var numRecords: Int32 {
        cram_container_get_num_records(pointer)
    }

    /// The number of bases in the container.
    public var numBases: Int64 {
        cram_container_get_num_bases(pointer)
    }

    /// The genomic coordinates of the container.
    ///
    /// - Returns: A tuple of (reference ID, start position, span).
    public func coordinates() -> (refID: Int32, start: Int64, span: Int64) {
        var refID: Int32 = 0
        var start: Int64 = 0
        var span: Int64 = 0
        cram_container_get_coords(pointer, &refID, &start, &span)
        return (refID, start, span)
    }

    deinit {
        cram_free_container(pointer)
    }
}

/// Helpers for CRAM file-level operations.
extension HTSFile {
    /// Get the number of CRAM containers in this file.
    ///
    /// Only valid for CRAM files.
    /// - Returns: The number of containers, or -1 on error or if not a CRAM file.
    public func cramNumContainers() -> Int64 {
        guard let fd = hts_shim_hts_get_cram_fd(pointer) else { return -1 }
        return cram_num_containers(fd)
    }
}
