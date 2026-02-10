import CHtslib

/// A reference-counted SAM/BAM/CRAM file header.
///
/// Contains the reference sequence dictionary (`@SQ` lines) and other header metadata.
/// The header is reference-counted and can be shared across iterators and records.
public final class SAMHeader: @unchecked Sendable {
    @usableFromInline
    internal let pointer: UnsafeMutablePointer<sam_hdr_t>
    private let owned: Bool

    internal init(pointer: UnsafeMutablePointer<sam_hdr_t>, owned: Bool = true) {
        self.pointer = pointer
        self.owned = owned
    }

    /// Create an empty SAM header.
    ///
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
    public convenience init() throws {
        guard let ptr = sam_hdr_init() else {
            throw HTSError.outOfMemory
        }
        self.init(pointer: ptr)
    }

    /// Parse a SAM header from its text representation.
    ///
    /// - Parameter text: The full SAM header text (including `@HD`, `@SQ` lines, etc.).
    /// - Throws: ``HTSError/parseFailed(message:)`` if parsing fails.
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

    /// The number of reference sequences (`@SQ` lines) in the header.
    public var nTargets: Int32 {
        sam_hdr_nref(pointer)
    }

    /// The full header text, or `nil` if unavailable.
    public var text: String? {
        guard let str = sam_hdr_str(pointer) else { return nil }
        return String(cString: str)
    }

    /// The length of the header text in bytes.
    public var length: Int {
        let len = sam_hdr_length(pointer)
        return len == Int.max ? 0 : len
    }

    /// Get the name of the reference sequence at the given index.
    ///
    /// - Parameter index: 0-based reference sequence index.
    /// - Returns: The sequence name, or `nil` if the index is out of range.
    public func targetName(at index: Int32) -> String? {
        guard let name = sam_hdr_tid2name(pointer, index) else { return nil }
        return String(cString: name)
    }

    /// Get the length of the reference sequence at the given index.
    ///
    /// - Parameter index: 0-based reference sequence index.
    /// - Returns: The sequence length in bases.
    public func targetLength(at index: Int32) -> Int64 {
        sam_hdr_tid2len(pointer, index)
    }

    /// Look up the numeric ID for a reference sequence by name.
    ///
    /// - Parameter name: Reference sequence name (e.g. `"chr1"`).
    /// - Returns: The 0-based target ID, or -1 if not found.
    public func targetID(forName name: String) -> Int32 {
        name.withCString { sam_hdr_name2tid(pointer, $0) }
    }

    /// Create an independent copy of this header.
    ///
    /// - Returns: A new ``SAMHeader``, or `nil` if duplication fails.
    public func copy() -> SAMHeader? {
        guard let dup = sam_hdr_dup(pointer) else { return nil }
        return SAMHeader(pointer: dup)
    }

    /// Write this header to an open HTS file.
    ///
    /// - Parameter file: The file to write to (must be opened for writing).
    /// - Throws: ``HTSError/headerWriteFailed`` on failure.
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
