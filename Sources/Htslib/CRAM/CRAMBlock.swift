// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// A CRAM block for low-level CRAM file access.
///
/// CRAM blocks are the basic units of data within containers. Most users
/// should access CRAM data through the format-agnostic ``HTSFile``/``SAMIterator`` layer.
/// This type is for advanced users building CRAM-specific tools.
public struct CRAMBlock: ~Copyable, @unchecked Sendable {
    nonisolated(unsafe) var pointer: OpaquePointer  // cram_block*

    /// Create a new empty CRAM block.
    ///
    /// - Parameters:
    ///   - contentType: The block content type.
    ///   - contentID: The block content identifier.
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
    public init(contentType: ContentType, contentID: Int32) throws {
        guard let ptr = cram_new_block(contentType.rawValue, contentID) else {
            throw HTSError.outOfMemory
        }
        self.pointer = ptr
    }

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    /// The content identifier for this block.
    public var contentID: Int32 {
        cram_block_get_content_id(pointer)
    }

    /// The compressed size of this block in bytes.
    public var compressedSize: Int32 {
        cram_block_get_comp_size(pointer)
    }

    /// The uncompressed size of this block in bytes.
    public var uncompressedSize: Int32 {
        cram_block_get_uncomp_size(pointer)
    }

    /// The CRC32 checksum of this block.
    public var crc32: Int32 {
        cram_block_get_crc32(pointer)
    }

    /// Uncompress this block's data.
    ///
    /// - Throws: ``HTSError/readFailed(code:)`` if decompression fails.
    public func uncompress() throws {
        let ret = cram_uncompress_block(pointer)
        if ret < 0 { throw HTSError.readFailed(code: Int32(ret)) }
    }

    /// CRAM block content types.
    public enum ContentType: Sendable {
        /// File header block.
        case fileHeader
        /// Compression header block.
        case compressionHeader
        /// Mapped slice block.
        case mappedSlice
        /// External data block.
        case external
        /// Core data block.
        case core

        internal var rawValue: cram_content_type {
            switch self {
            case .fileHeader: return FILE_HEADER
            case .compressionHeader: return COMPRESSION_HEADER
            case .mappedSlice: return MAPPED_SLICE
            case .external: return EXTERNAL
            case .core: return CORE
            }
        }
    }

    deinit {
        cram_free_block(pointer)
    }
}
