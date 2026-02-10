import CHtslib
import CHTSlibShims

public struct BGZFFile: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<BGZF>

    public init(path: String, mode: String) throws {
        guard let fp = path.withCString({ p in
            mode.withCString { m in bgzf_open(p, m) }
        }) else {
            throw HTSError.openFailed(path: path, mode: mode)
        }
        self.pointer = fp
    }

    public var virtualOffset: Int64 {
        hts_shim_bgzf_tell(pointer)
    }

    public var isCompressed: Bool {
        pointer.pointee.is_compressed != 0
    }

    public func read(into buffer: UnsafeMutableRawPointer, length: Int) throws -> Int {
        let ret = bgzf_read(pointer, buffer, length)
        if ret < 0 { throw HTSError.readFailed(code: Int32(ret)) }
        return Int(ret)
    }

    public func write(from buffer: UnsafeRawPointer, length: Int) throws -> Int {
        let ret = bgzf_write(pointer, buffer, length)
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
        return Int(ret)
    }

    public func seek(to virtualOffset: Int64) throws {
        let ret = bgzf_seek(pointer, virtualOffset, 0) // SEEK_SET
        if ret < 0 { throw HTSError.seekFailed }
    }

    public func flush() throws {
        let ret = bgzf_flush(pointer)
        if ret < 0 { throw HTSError.writeFailed(code: ret) }
    }

    public func setThreadPool(_ pool: borrowing ThreadPool, queueSize: Int32 = 0) -> Int32 {
        bgzf_thread_pool(pointer, pool.pointer, queueSize)
    }

    deinit {
        bgzf_close(pointer)
    }
}
