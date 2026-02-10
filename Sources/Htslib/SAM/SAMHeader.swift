import CHtslib

public final class SAMHeader: @unchecked Sendable {
    @usableFromInline
    internal let pointer: UnsafeMutablePointer<sam_hdr_t>
    private let owned: Bool

    internal init(pointer: UnsafeMutablePointer<sam_hdr_t>, owned: Bool = true) {
        self.pointer = pointer
        self.owned = owned
    }

    public convenience init() throws {
        guard let ptr = sam_hdr_init() else {
            throw HTSError.outOfMemory
        }
        self.init(pointer: ptr)
    }

    public convenience init(text: String) throws {
        guard let ptr = text.withCString({ sam_hdr_parse(text.utf8.count, $0) }) else {
            throw HTSError.parseFailed(message: "Failed to parse SAM header text")
        }
        self.init(pointer: ptr)
    }

    /// Read header from an open HTSFile
    internal convenience init(from file: borrowing HTSFile) throws {
        guard let ptr = sam_hdr_read(file.pointer) else {
            throw HTSError.headerReadFailed
        }
        self.init(pointer: ptr)
    }

    public var nTargets: Int32 {
        sam_hdr_nref(pointer)
    }

    public var text: String? {
        guard let str = sam_hdr_str(pointer) else { return nil }
        return String(cString: str)
    }

    public var length: Int {
        let len = sam_hdr_length(pointer)
        return len == Int.max ? 0 : len
    }

    public func targetName(at index: Int32) -> String? {
        guard let name = sam_hdr_tid2name(pointer, index) else { return nil }
        return String(cString: name)
    }

    public func targetLength(at index: Int32) -> Int64 {
        sam_hdr_tid2len(pointer, index)
    }

    public func targetID(forName name: String) -> Int32 {
        name.withCString { sam_hdr_name2tid(pointer, $0) }
    }

    public func copy() -> SAMHeader? {
        guard let dup = sam_hdr_dup(pointer) else { return nil }
        return SAMHeader(pointer: dup)
    }

    public func write(to file: borrowing HTSFile) throws {
        let ret = sam_hdr_write(file.pointer, pointer)
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    deinit {
        if owned {
            sam_hdr_destroy(pointer)
        }
    }
}
