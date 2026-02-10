import CHtslib
import CHTSlibShims

public struct AuxiliaryData: @unchecked Sendable {
    nonisolated(unsafe) private let record: UnsafePointer<bam1_t>

    internal init(record: UnsafePointer<bam1_t>) {
        self.record = record
    }

    /// Get raw aux tag data. Returns nil if tag not found.
    private func rawGet(_ tag: String) -> UnsafePointer<UInt8>? {
        precondition(tag.count == 2, "Aux tags must be exactly 2 characters")
        return tag.withCString { tagPtr in
            bam_aux_get(record, tagPtr).map { UnsafePointer($0) }
        }
    }

    public func contains(_ tag: String) -> Bool {
        rawGet(tag) != nil
    }

    public func integer(forTag tag: String) -> Int64? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_aux2i(UnsafeMutablePointer(mutating: data))
        return errno == EINVAL ? nil : val
    }

    public func float(forTag tag: String) -> Double? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_aux2f(UnsafeMutablePointer(mutating: data))
        return errno == EINVAL ? nil : val
    }

    public func character(forTag tag: String) -> Character? {
        guard let data = rawGet(tag) else { return nil }
        let val = bam_aux2A(UnsafeMutablePointer(mutating: data))
        return val == 0 ? nil : Character(UnicodeScalar(UInt8(bitPattern: val)))
    }

    public func string(forTag tag: String) -> String? {
        guard let data = rawGet(tag) else { return nil }
        guard let str = bam_aux2Z(UnsafeMutablePointer(mutating: data)) else { return nil }
        return String(cString: str)
    }

    public func arrayLength(forTag tag: String) -> UInt32? {
        guard let data = rawGet(tag) else { return nil }
        let len = bam_auxB_len(UnsafeMutablePointer(mutating: data))
        return len == 0 && errno == EINVAL ? nil : len
    }

    public func arrayInteger(forTag tag: String, index: UInt32) -> Int64? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_auxB2i(UnsafeMutablePointer(mutating: data), index)
        return errno == EINVAL ? nil : val
    }

    public func arrayFloat(forTag tag: String, index: UInt32) -> Double? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_auxB2f(UnsafeMutablePointer(mutating: data), index)
        return errno == EINVAL ? nil : val
    }
}
