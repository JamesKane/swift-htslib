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

    deinit {
        hts_close(pointer)
    }

    // Internal access for other types
    @usableFromInline
    var rawPointer: UnsafeMutablePointer<htsFile> { pointer }
}
