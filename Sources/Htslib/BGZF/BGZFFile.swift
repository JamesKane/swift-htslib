// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// A handle for reading and writing BGZF-compressed files.
///
/// BGZF (Blocked GNU Zip Format) is the compression format used by BAM, BCF,
/// and tabix-indexed files. `BGZFFile` provides direct access to the compressed
/// stream with virtual-offset-based seeking. This is a move-only type that closes
/// the file on deinitialization.
public struct BGZFFile: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<BGZF>

    /// Open a BGZF file at the given path.
    ///
    /// - Parameters:
    ///   - path: File system path.
    ///   - mode: Open mode (`"r"` for reading, `"w"` for writing).
    /// - Throws: ``HTSError/openFailed(path:mode:)`` if the file cannot be opened.
    public init(path: String, mode: String) throws {
        guard let fp = path.withCString({ p in
            mode.withCString { m in bgzf_open(p, m) }
        }) else {
            throw HTSError.openFailed(path: path, mode: mode)
        }
        self.pointer = fp
    }

    /// The current virtual file offset (encodes both block offset and within-block offset).
    public var virtualOffset: Int64 {
        hts_shim_bgzf_tell(pointer)
    }

    /// Whether the underlying file is BGZF-compressed (as opposed to plain gzip or uncompressed).
    public var isCompressed: Bool {
        pointer.pointee.is_compressed != 0
    }

    /// Read decompressed bytes from the file into a buffer.
    ///
    /// - Parameters:
    ///   - buffer: Destination buffer.
    ///   - length: Maximum number of bytes to read.
    /// - Returns: The number of bytes actually read.
    /// - Throws: ``HTSError/readFailed(code:)`` on I/O error.
    public func read(into buffer: UnsafeMutableRawPointer, length: Int) throws -> Int {
        let ret = bgzf_read(pointer, buffer, length)
        if ret < 0 { throw HTSError.readFailed(code: Int32(ret)) }
        return Int(ret)
    }

    /// Write bytes to the file (will be BGZF-compressed).
    ///
    /// - Parameters:
    ///   - buffer: Source buffer.
    ///   - length: Number of bytes to write.
    /// - Returns: The number of bytes actually written.
    /// - Throws: ``HTSError/writeFailed(code:)`` on I/O error.
    public func write(from buffer: UnsafeRawPointer, length: Int) throws -> Int {
        let ret = bgzf_write(pointer, buffer, length)
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
        return Int(ret)
    }

    /// Seek to a virtual file offset.
    ///
    /// - Parameter virtualOffset: The target virtual offset (as returned by ``virtualOffset``).
    /// - Throws: ``HTSError/seekFailed`` if the seek fails.
    public func seek(to virtualOffset: Int64) throws {
        let ret = bgzf_seek(pointer, virtualOffset, 0) // SEEK_SET
        if ret < 0 { throw HTSError.seekFailed }
    }

    /// Flush any buffered data to the file.
    ///
    /// - Throws: ``HTSError/writeFailed(code:)`` if flushing fails.
    public func flush() throws {
        let ret = bgzf_flush(pointer)
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    /// Attach a shared thread pool for parallel compression/decompression.
    ///
    /// - Parameters:
    ///   - pool: The ``ThreadPool`` to use.
    ///   - queueSize: Size of the task queue (0 for default).
    /// - Returns: 0 on success, negative on failure.
    public func setThreadPool(_ pool: borrowing ThreadPool, queueSize: Int32 = 0) -> Int32 {
        bgzf_thread_pool(pointer, pool.pointer, queueSize)
    }

    deinit {
        bgzf_close(pointer)
    }
}
