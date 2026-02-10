import CHtslib

/// A shared thread pool for parallel htslib I/O operations.
///
/// Create a single `ThreadPool` and attach it to multiple file handles
/// via ``HTSFile/setThreadPool(_:queueSize:)`` to share threads across files.
/// This is a move-only type that destroys the pool on deinitialization.
public struct ThreadPool: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: OpaquePointer

    /// Create a thread pool with the specified number of worker threads.
    ///
    /// - Parameter threads: Number of threads in the pool.
    /// - Throws: ``HTSError/outOfMemory`` if the pool cannot be allocated.
    public init(threads: Int32) throws {
        guard let pool = hts_tpool_init(threads) else {
            throw HTSError.outOfMemory
        }
        self.pointer = pool
    }

    /// The number of worker threads in this pool.
    public var size: Int32 {
        hts_tpool_size(pointer)
    }

    deinit {
        hts_tpool_destroy(pointer)
    }
}
