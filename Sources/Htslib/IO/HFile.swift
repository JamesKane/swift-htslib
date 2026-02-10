import CHtslib
import CHTSlibShims

public struct HFile: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<hFILE>

    public init(path: String, mode: String) throws {
        guard let fp = path.withCString({ p in
            mode.withCString { m in hts_shim_hopen(p, m) }
        }) else {
            throw HTSError.openFailed(path: path, mode: mode)
        }
        self.pointer = fp
    }

    public var errorCode: Int32 {
        hts_shim_herrno(pointer)
    }

    public func clearError() {
        hts_shim_hclearerr(pointer)
    }

    public var offset: off_t {
        hts_shim_htell(pointer)
    }

    public func read(into buffer: UnsafeMutableRawPointer, length: Int) throws -> Int {
        let ret = hts_shim_hread(pointer, buffer, length)
        if ret < 0 { throw HTSError.readFailed(code: Int32(ret)) }
        return Int(ret)
    }

    public func write(from buffer: UnsafeRawPointer, length: Int) throws -> Int {
        let ret = hts_shim_hwrite(pointer, buffer, length)
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
        return Int(ret)
    }

    public func seek(to offset: off_t, whence: Int32 = 0) throws -> off_t {
        let ret = hseek(pointer, offset, whence)
        if ret < 0 { throw HTSError.seekFailed }
        return ret
    }

    public static func isRemote(path: String) -> Bool {
        path.withCString { hisremote($0) } != 0
    }

    deinit {
        _ = hclose(pointer)
    }
}
