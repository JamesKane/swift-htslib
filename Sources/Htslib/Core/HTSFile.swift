import CHtslib
import CHTSlibShims

public struct HTSFile: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<htsFile>

    public let path: String
    public let mode: String

    public init(path: String, mode: String) throws {
        guard let fp = hts_open(path, mode) else {
            throw HTSError.openFailed(path: path, mode: mode)
        }
        self.pointer = fp
        self.path = path
        self.mode = mode
    }

    public var format: HTSFileFormat {
        HTSFileFormat(from: pointer.pointee.format.format)
    }

    public var category: HTSFormatCategory {
        HTSFormatCategory(from: pointer.pointee.format.category)
    }

    public var isWrite: Bool {
        pointer.pointee.is_write != 0
    }

    @discardableResult
    public func setThreads(_ n: Int32) -> Int32 {
        hts_set_threads(pointer, n)
    }

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
