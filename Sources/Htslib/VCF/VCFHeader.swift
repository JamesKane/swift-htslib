import CHtslib
import CHTSlibShims

public final class VCFHeader: @unchecked Sendable {
    @usableFromInline
    internal let pointer: UnsafeMutablePointer<bcf_hdr_t>
    private let owned: Bool

    internal init(pointer: UnsafeMutablePointer<bcf_hdr_t>, owned: Bool = true) {
        self.pointer = pointer
        self.owned = owned
    }

    public convenience init(mode: String = "w") throws {
        guard let ptr = mode.withCString({ bcf_hdr_init($0) }) else {
            throw HTSError.outOfMemory
        }
        self.init(pointer: ptr)
    }

    internal convenience init(from file: borrowing HTSFile) throws {
        guard let ptr = bcf_hdr_read(file.pointer) else {
            throw HTSError.headerReadFailed
        }
        self.init(pointer: ptr)
    }

    public var nSamples: Int32 {
        hts_shim_bcf_hdr_nsamples(pointer)
    }

    public var samples: [String] {
        let n = Int(nSamples)
        guard n > 0, let s = pointer.pointee.samples else { return [] }
        return (0..<n).compactMap { i in
            guard let name = s[i] else { return nil }
            return String(cString: name)
        }
    }

    public func addSample(_ name: String) -> Int32 {
        name.withCString { bcf_hdr_add_sample(pointer, $0) }
    }

    public func append(line: String) -> Int32 {
        line.withCString { bcf_hdr_append(pointer, $0) }
    }

    public func sync() -> Int32 {
        bcf_hdr_sync(pointer)
    }

    public func headerID(for type: Int32, name: String) -> Int32 {
        name.withCString { bcf_hdr_id2int(pointer, type, $0) }
    }

    public func copy() -> VCFHeader? {
        guard let dup = bcf_hdr_dup(pointer) else { return nil }
        return VCFHeader(pointer: dup)
    }

    public func write(to file: borrowing HTSFile) throws {
        let ret = bcf_hdr_write(file.pointer, pointer)
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    deinit {
        if owned { bcf_hdr_destroy(pointer) }
    }
}
