import CHtslib
import CHTSlibShims

/// A reference-counted VCF/BCF file header.
///
/// Contains the contig dictionary, INFO/FORMAT/FILTER definitions, and sample names.
/// The header is reference-counted and can be shared across iterators and records.
public final class VCFHeader: @unchecked Sendable {
    @usableFromInline
    internal let pointer: UnsafeMutablePointer<bcf_hdr_t>
    private let owned: Bool

    internal init(pointer: UnsafeMutablePointer<bcf_hdr_t>, owned: Bool = true) {
        self.pointer = pointer
        self.owned = owned
    }

    /// Create an empty VCF header.
    ///
    /// - Parameter mode: Header mode string (`"w"` for writing, `"r"` for reading).
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
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

    /// The number of samples defined in the header.
    public var nSamples: Int32 {
        hts_shim_bcf_hdr_nsamples(pointer)
    }

    /// The sample names defined in the header.
    public var samples: [String] {
        let n = Int(nSamples)
        guard n > 0, let s = pointer.pointee.samples else { return [] }
        return (0..<n).compactMap { i in
            guard let name = s[i] else { return nil }
            return String(cString: name)
        }
    }

    /// Add a sample name to the header.
    ///
    /// - Parameter name: The sample name to add.
    /// - Returns: 0 on success, negative on failure.
    public func addSample(_ name: String) -> Int32 {
        name.withCString { bcf_hdr_add_sample(pointer, $0) }
    }

    /// Append a header line (e.g. `##INFO=<...>` or `##contig=<...>`).
    ///
    /// - Parameter line: The full header line text.
    /// - Returns: 0 on success, negative on failure.
    public func append(line: String) -> Int32 {
        line.withCString { bcf_hdr_append(pointer, $0) }
    }

    /// Synchronize the header after modifications.
    ///
    /// Must be called after adding samples or header lines before writing records.
    /// - Returns: 0 on success, negative on failure.
    public func sync() -> Int32 {
        bcf_hdr_sync(pointer)
    }

    /// Look up a header dictionary ID by type and name.
    ///
    /// - Parameters:
    ///   - type: The dictionary type (`BCF_DT_ID`, `BCF_DT_CTG`, `BCF_DT_SAMPLE`).
    ///   - name: The name to look up.
    /// - Returns: The numeric ID, or -1 if not found.
    public func headerID(for type: Int32, name: String) -> Int32 {
        name.withCString { bcf_hdr_id2int(pointer, type, $0) }
    }

    /// Create an independent copy of this header.
    ///
    /// - Returns: A new ``VCFHeader``, or `nil` if duplication fails.
    public func copy() -> VCFHeader? {
        guard let dup = bcf_hdr_dup(pointer) else { return nil }
        return VCFHeader(pointer: dup)
    }

    /// Write this header to an open HTS file.
    ///
    /// - Parameter file: The file to write to (must be opened for writing).
    /// - Throws: ``HTSError/headerWriteFailed`` on failure.
    public func write(to file: borrowing HTSFile) throws {
        let ret = bcf_hdr_write(file.pointer, pointer)
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    deinit {
        if owned { bcf_hdr_destroy(pointer) }
    }
}
