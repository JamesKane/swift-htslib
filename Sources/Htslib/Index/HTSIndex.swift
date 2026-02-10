import CHtslib

public struct HTSIndex: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: OpaquePointer  // hts_idx_t*

    /// Load an index for the given file
    public init(path: String, format: IndexFormat = .auto) throws {
        guard let idx = path.withCString({ hts_idx_load3($0, nil, format.rawValue, 0) }) else {
            throw HTSError.indexLoadFailed(path: path)
        }
        self.pointer = idx
    }

    internal init(pointer: OpaquePointer) {
        self.pointer = pointer
    }

    public enum IndexFormat: Int32, Sendable {
        case auto = 0   // HTS_FMT_CSI or HTS_FMT_BAI auto-detect
        case bai = 1     // HTS_FMT_BAI
        case csi = 2     // HTS_FMT_CSI
        case tbi = 3     // HTS_FMT_TBI
    }

    /// Get the number of reference sequences in the index
    public func nSequences() -> Int32 {
        hts_idx_nseq(pointer)
    }

    /// Build an index for a file
    public static func build(path: String, minShift: Int32 = 0, nThreads: Int32 = 0) throws {
        let ret = path.withCString { sam_index_build3($0, nil, minShift, nThreads) }
        if ret < 0 {
            throw HTSError.indexBuildFailed(path: path, code: ret)
        }
    }

    deinit {
        hts_idx_destroy(pointer)
    }
}
