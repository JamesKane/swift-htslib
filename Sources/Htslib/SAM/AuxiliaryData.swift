// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

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

// MARK: - MutableAuxiliaryData

/// Provides mutable access to the auxiliary (tag) data of a BAM record.
///
/// Use this type to update, append, or delete auxiliary tags on a record.
/// Obtain an instance via ``BAMRecord/mutableAuxiliaryData``.
public struct MutableAuxiliaryData: @unchecked Sendable {
    nonisolated(unsafe) private let record: UnsafeMutablePointer<bam1_t>

    internal init(record: UnsafeMutablePointer<bam1_t>) {
        self.record = record
    }

    /// Get raw aux tag data (mutable). Returns nil if tag not found.
    private func rawGet(_ tag: String) -> UnsafeMutablePointer<UInt8>? {
        tag.withCString { tagPtr in
            bam_aux_get(record, tagPtr)
        }
    }

    /// Update or append an integer auxiliary tag.
    ///
    /// If the tag already exists, its value is replaced. If not, it is appended.
    /// - Parameters:
    ///   - tag: A two-character tag name.
    ///   - value: The integer value to set.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func updateInt(tag: String, value: Int64) throws {
        precondition(tag.count == 2, "Aux tags must be exactly 2 characters")
        let ret = tag.withCString { bam_aux_update_int(record, $0, value) }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update or append a floating-point auxiliary tag.
    ///
    /// - Parameters:
    ///   - tag: A two-character tag name.
    ///   - value: The float value to set.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func updateFloat(tag: String, value: Float) throws {
        precondition(tag.count == 2, "Aux tags must be exactly 2 characters")
        let ret = tag.withCString { bam_aux_update_float(record, $0, value) }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Update or append a string auxiliary tag.
    ///
    /// - Parameters:
    ///   - tag: A two-character tag name.
    ///   - value: The string value to set.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func updateString(tag: String, value: String) throws {
        precondition(tag.count == 2, "Aux tags must be exactly 2 characters")
        let ret = tag.withCString { tagPtr in
            value.withCString { valPtr in
                bam_aux_update_str(record, tagPtr, Int32(value.utf8.count + 1), valPtr)
            }
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Delete an auxiliary tag from the record.
    ///
    /// - Parameter tag: A two-character tag name.
    /// - Throws: ``HTSError/tagNotFound(tag:)`` if the tag is not present,
    ///           ``HTSError/writeFailed(code:)`` on other failure.
    public func delete(tag: String) throws {
        precondition(tag.count == 2, "Aux tags must be exactly 2 characters")
        guard let data = rawGet(tag) else {
            throw HTSError.tagNotFound(tag: tag)
        }
        let ret = bam_aux_del(record, data)
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }

    /// Append raw auxiliary data to the record.
    ///
    /// - Parameters:
    ///   - tag: A two-character tag name.
    ///   - type: The BAM type character (`'A'`, `'i'`, `'f'`, `'Z'`, `'H'`, `'B'`).
    ///   - length: Length of the data in bytes.
    ///   - data: Pointer to the raw data.
    /// - Throws: ``HTSError/writeFailed(code:)`` on failure.
    public func append(tag: String, type: Character, length: Int, data: UnsafePointer<UInt8>) throws {
        precondition(tag.count == 2, "Aux tags must be exactly 2 characters")
        let ret = tag.withCString { tagPtr in
            bam_aux_append(record, tagPtr, Int8(bitPattern: type.asciiValue ?? 0), Int32(length), data)
        }
        if ret < 0 { throw HTSError.writeFailed(code: Int32(ret)) }
    }
}
