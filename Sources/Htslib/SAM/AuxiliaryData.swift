import CHtslib
import CHTSlibShims

/// Provides typed access to the auxiliary (tag) data of a BAM record.
///
/// Each auxiliary tag is identified by a two-character string (e.g. `"NM"`, `"RG"`).
/// Use the typed accessors to retrieve values by tag name.
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

    /// Check whether the given auxiliary tag is present on this record.
    ///
    /// - Parameter tag: A two-character tag name (e.g. `"NM"`).
    /// - Returns: `true` if the tag exists.
    public func contains(_ tag: String) -> Bool {
        rawGet(tag) != nil
    }

    /// Get an integer value for the given tag.
    ///
    /// Works with BAM types `c`, `C`, `s`, `S`, `i`, `I`.
    /// - Parameter tag: A two-character tag name.
    /// - Returns: The integer value, or `nil` if the tag is absent or not an integer type.
    public func integer(forTag tag: String) -> Int64? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_aux2i(UnsafeMutablePointer(mutating: data))
        return errno == EINVAL ? nil : val
    }

    /// Get a floating-point value for the given tag.
    ///
    /// Works with BAM types `f` and `d`.
    /// - Parameter tag: A two-character tag name.
    /// - Returns: The float value, or `nil` if the tag is absent or not a float type.
    public func float(forTag tag: String) -> Double? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_aux2f(UnsafeMutablePointer(mutating: data))
        return errno == EINVAL ? nil : val
    }

    /// Get a single character value for the given tag.
    ///
    /// Works with BAM type `A`.
    /// - Parameter tag: A two-character tag name.
    /// - Returns: The character, or `nil` if the tag is absent or not a character type.
    public func character(forTag tag: String) -> Character? {
        guard let data = rawGet(tag) else { return nil }
        let val = bam_aux2A(UnsafeMutablePointer(mutating: data))
        return val == 0 ? nil : Character(UnicodeScalar(UInt8(bitPattern: val)))
    }

    /// Get a string value for the given tag.
    ///
    /// Works with BAM types `Z` and `H`.
    /// - Parameter tag: A two-character tag name.
    /// - Returns: The string value, or `nil` if the tag is absent or not a string type.
    public func string(forTag tag: String) -> String? {
        guard let data = rawGet(tag) else { return nil }
        guard let str = bam_aux2Z(UnsafeMutablePointer(mutating: data)) else { return nil }
        return String(cString: str)
    }

    /// Get the length of an array-typed tag.
    ///
    /// Works with BAM type `B`.
    /// - Parameter tag: A two-character tag name.
    /// - Returns: The number of elements, or `nil` if the tag is absent or not an array.
    public func arrayLength(forTag tag: String) -> UInt32? {
        guard let data = rawGet(tag) else { return nil }
        let len = bam_auxB_len(UnsafeMutablePointer(mutating: data))
        return len == 0 && errno == EINVAL ? nil : len
    }

    /// Get an integer element from an array-typed tag.
    ///
    /// - Parameters:
    ///   - tag: A two-character tag name.
    ///   - index: 0-based element index within the array.
    /// - Returns: The integer value, or `nil` if the tag is absent or the index is out of range.
    public func arrayInteger(forTag tag: String, index: UInt32) -> Int64? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_auxB2i(UnsafeMutablePointer(mutating: data), index)
        return errno == EINVAL ? nil : val
    }

    /// Get a floating-point element from an array-typed tag.
    ///
    /// - Parameters:
    ///   - tag: A two-character tag name.
    ///   - index: 0-based element index within the array.
    /// - Returns: The float value, or `nil` if the tag is absent or the index is out of range.
    public func arrayFloat(forTag tag: String, index: UInt32) -> Double? {
        guard let data = rawGet(tag) else { return nil }
        errno = 0
        let val = bam_auxB2f(UnsafeMutablePointer(mutating: data), index)
        return errno == EINVAL ? nil : val
    }
}
