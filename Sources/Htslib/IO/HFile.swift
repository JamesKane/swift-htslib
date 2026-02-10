import CHtslib
import CHTSlibShims

/// A low-level file handle wrapping htslib's `hFILE` abstraction.
///
/// `HFile` provides byte-level read/write/seek operations and supports both
/// local and remote (e.g. HTTP, S3) file paths. This is a move-only type
/// that closes the handle on deinitialization.
public struct HFile: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<hFILE>

    /// Open a file at the given path.
    ///
    /// - Parameters:
    ///   - path: File path (local or remote URL).
    ///   - mode: Open mode (`"r"` for reading, `"w"` for writing).
    /// - Throws: ``HTSError/openFailed(path:mode:)`` if the file cannot be opened.
    public init(path: String, mode: String) throws {
        guard let fp = path.withCString({ p in
            mode.withCString { m in hts_shim_hopen(p, m) }
        }) else {
            throw HTSError.openFailed(path: path, mode: mode)
        }
        self.pointer = fp
    }

    /// The current error code (errno value), or 0 if no error.
    public var errorCode: Int32 {
        hts_shim_herrno(pointer)
    }

    /// Clear the error state of this file handle.
    public func clearError() {
        hts_shim_hclearerr(pointer)
    }

    /// The current byte offset in the file.
    public var offset: off_t {
        hts_shim_htell(pointer)
    }

    /// Read bytes from the file into a buffer.
    ///
    /// - Parameters:
    ///   - buffer: Destination buffer.
    ///   - length: Maximum number of bytes to read.
    /// - Returns: The number of bytes actually read.
    /// - Throws: ``HTSError/readFailed(code:)`` on I/O error.
    public func read(into buffer: UnsafeMutableRawPointer, length: Int) throws -> Int {
        let ret = hts_shim_hread(pointer, buffer, length)
        if ret < 0 { throw HTSError.readFailed(code: Int32(ret)) }
        return Int(ret)
    }

    /// Write bytes from a buffer to the file.
    ///
    /// - Parameters:
    ///   - buffer: Source buffer.
    ///   - length: Number of bytes to write.
    /// - Returns: The number of bytes actually written.
    /// - Throws: ``HTSError/writeFailed(code:)`` on I/O error.
    public func write(from buffer: UnsafeRawPointer, length: Int) throws -> Int {
        let ret = hts_shim_hwrite(pointer, buffer, length)
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
        return Int(ret)
    }

    /// Seek to a byte offset in the file.
    ///
    /// - Parameters:
    ///   - offset: The target byte offset.
    ///   - whence: Seek origin (`SEEK_SET` = 0, `SEEK_CUR` = 1, `SEEK_END` = 2).
    /// - Returns: The resulting offset from the beginning of the file.
    /// - Throws: ``HTSError/seekFailed`` if the seek fails.
    public func seek(to offset: off_t, whence: Int32 = 0) throws -> off_t {
        let ret = hseek(pointer, offset, whence)
        if ret < 0 { throw HTSError.seekFailed }
        return ret
    }

    /// Check whether a path refers to a remote resource (HTTP, S3, etc.).
    ///
    /// - Parameter path: The file path or URL to check.
    /// - Returns: `true` if the path is a remote URL.
    public static func isRemote(path: String) -> Bool {
        path.withCString { hisremote($0) } != 0
    }

    deinit {
        _ = hclose(pointer)
    }
}
