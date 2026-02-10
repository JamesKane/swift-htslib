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

    // MARK: - Extended operations

    /// Remove a header line by type and key.
    ///
    /// - Parameters:
    ///   - type: The header line type (`BCF_HL_FLT`, `BCF_HL_INFO`, `BCF_HL_FMT`,
    ///     `BCF_HL_CTG`, `BCF_HL_STR`, `BCF_HL_GEN`).
    ///   - key: The key (ID) to remove.
    public func remove(type: Int32, key: String) {
        key.withCString { bcf_hdr_remove(pointer, type, $0) }
    }

    /// Set which samples to include when reading records.
    ///
    /// - Parameters:
    ///   - samples: Comma-separated sample names, `-` for no samples, or a filename prefixed with `file:`.
    ///   - isFile: If `true`, `samples` is a filename containing sample names.
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func setSamples(_ samples: String, isFile: Bool = false) -> Int32 {
        let str = isFile ? "file:\(samples)" : samples
        return str.withCString { bcf_hdr_set_samples(pointer, $0, 0) }
    }

    /// The names of all contigs (sequences) defined in the header.
    public var sequenceNames: [String] {
        var n: Int32 = 0
        guard let names = bcf_hdr_seqnames(pointer, &n) else { return [] }
        defer { free(names) }
        return (0..<Int(n)).compactMap { i in
            guard let s = names[i] else { return nil }
            return String(cString: s)
        }
    }

    /// The VCF version string (e.g. `"VCFv4.3"`).
    public var version: String? {
        guard let v = bcf_hdr_get_version(pointer) else { return nil }
        return String(cString: v)
    }

    /// Set the VCF version string.
    ///
    /// - Parameter version: The version string (e.g. `"VCFv4.3"`).
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func setVersion(_ version: String) -> Int32 {
        version.withCString { bcf_hdr_set_version(pointer, $0) }
    }

    /// Create a new header containing only the specified samples.
    ///
    /// - Parameter samples: Array of sample names to include.
    /// - Returns: A new ``VCFHeader`` with only the specified samples, or `nil` on failure.
    public func subset(samples: [String]) -> VCFHeader? {
        let n = Int32(samples.count)
        let imap = UnsafeMutablePointer<Int32>.allocate(capacity: samples.count)
        defer { imap.deallocate() }
        // Create a C array of C strings
        let cStrings = samples.map { strdup($0) }
        defer { cStrings.forEach { free($0) } }
        let result = cStrings.withUnsafeBufferPointer { buf in
            let ptrs = UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>.allocate(capacity: samples.count)
            for i in 0..<samples.count {
                ptrs[i] = buf[i]
            }
            defer { ptrs.deallocate() }
            return bcf_hdr_subset(pointer, n, ptrs, imap)
        }
        guard let hdr = result else { return nil }
        return VCFHeader(pointer: hdr)
    }

    deinit {
        if owned { bcf_hdr_destroy(pointer) }
    }
}
