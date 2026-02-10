import CHtslib

public struct FASTAIndex: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: OpaquePointer  // faidx_t*

    public init(path: String, buildIndex: Bool = false) throws {
        let flags: Int32 = buildIndex ? 0x01 : 0  // FAI_CREATE
        guard let fai = path.withCString({ fai_load3($0, nil, nil, flags) }) else {
            throw HTSError.indexLoadFailed(path: path)
        }
        self.pointer = fai
    }

    public var sequenceCount: Int {
        Int(faidx_nseq(pointer))
    }

    public func sequenceName(at index: Int) -> String? {
        guard let name = faidx_iseq(pointer, Int32(index)) else { return nil }
        return String(cString: name)
    }

    public func sequenceLength(name: String) -> Int64 {
        name.withCString { faidx_seq_len64(pointer, $0) }
    }

    public func hasSequence(name: String) -> Bool {
        name.withCString { faidx_has_seq(pointer, $0) } != 0
    }

    /// Fetch a region string like "chr1:1000-2000"
    public func fetch(region: String) throws -> String {
        var len: Int32 = 0
        guard let seq = region.withCString({ fai_fetch(pointer, $0, &len) }) else {
            throw HTSError.regionParseFailed(region: region)
        }
        defer { free(UnsafeMutablePointer(mutating: seq)) }
        return String(cString: seq)
    }

    /// Fetch a specific range on a named sequence
    public func fetch(sequence: String, start: Int64, end: Int64) throws -> String {
        var len: Int64 = 0
        guard let seq = sequence.withCString({
            faidx_fetch_seq64(pointer, $0, start, end, &len)
        }) else {
            throw HTSError.regionParseFailed(region: "\(sequence):\(start)-\(end)")
        }
        defer { free(UnsafeMutablePointer(mutating: seq)) }
        return String(cString: seq)
    }

    public func setThreadPool(_ pool: borrowing ThreadPool, queueSize: Int32 = 0) {
        fai_thread_pool(pointer, pool.pointer, queueSize)
    }

    deinit {
        fai_destroy(pointer)
    }
}
