import CHtslib

public struct ThreadPool: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: OpaquePointer

    public init(threads: Int32) throws {
        guard let pool = hts_tpool_init(threads) else {
            throw HTSError.outOfMemory
        }
        self.pointer = pool
    }

    public var size: Int32 {
        hts_tpool_size(pointer)
    }

    deinit {
        hts_tpool_destroy(pointer)
    }
}
