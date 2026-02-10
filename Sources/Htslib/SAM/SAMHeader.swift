import CHtslib
import CHTSlibShims

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

    // MARK: - Line manipulation

    /// Add one or more header lines from a text string.
    ///
    /// Lines should be separated by newlines and include the `@` prefix.
    /// - Parameter text: The header text to add (e.g. `"@SQ\tSN:chr1\tLN:248956422"`).
    /// - Throws: ``HTSError/headerWriteFailed`` on failure.
    public func addLines(_ text: String) throws {
        let ret = text.withCString { sam_hdr_add_lines(pointer, $0, 0) }
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    /// Add a single header line with key-value pairs.
    ///
    /// - Parameters:
    ///   - type: The two-character record type (e.g. `"SQ"`, `"RG"`, `"PG"`).
    ///   - keyValues: An array of key-value string pairs (e.g. `[("SN","chr1"), ("LN","100")]`).
    ///     Supports 1-5 pairs.
    /// - Throws: ``HTSError/headerWriteFailed`` on failure.
    /// - Throws: ``HTSError/invalidArgument(message:)`` if more than 5 pairs are provided.
    public func addLine(type: String, keyValues: [(String, String)]) throws {
        let ret: Int32
        switch keyValues.count {
        case 1:
            ret = type.withCString { t in
                keyValues[0].0.withCString { k1 in
                    keyValues[0].1.withCString { v1 in
                        hts_shim_sam_hdr_add_line_1(pointer, t, k1, v1)
                    }
                }
            }
        case 2:
            ret = type.withCString { t in
                keyValues[0].0.withCString { k1 in keyValues[0].1.withCString { v1 in
                keyValues[1].0.withCString { k2 in keyValues[1].1.withCString { v2 in
                    hts_shim_sam_hdr_add_line_2(pointer, t, k1, v1, k2, v2)
                }}}}
            }
        case 3:
            ret = type.withCString { t in
                keyValues[0].0.withCString { k1 in keyValues[0].1.withCString { v1 in
                keyValues[1].0.withCString { k2 in keyValues[1].1.withCString { v2 in
                keyValues[2].0.withCString { k3 in keyValues[2].1.withCString { v3 in
                    hts_shim_sam_hdr_add_line_3(pointer, t, k1, v1, k2, v2, k3, v3)
                }}}}}}
            }
        case 4:
            ret = type.withCString { t in
                keyValues[0].0.withCString { k1 in keyValues[0].1.withCString { v1 in
                keyValues[1].0.withCString { k2 in keyValues[1].1.withCString { v2 in
                keyValues[2].0.withCString { k3 in keyValues[2].1.withCString { v3 in
                keyValues[3].0.withCString { k4 in keyValues[3].1.withCString { v4 in
                    hts_shim_sam_hdr_add_line_4(pointer, t, k1, v1, k2, v2, k3, v3, k4, v4)
                }}}}}}}}
            }
        case 5:
            ret = type.withCString { t in
                keyValues[0].0.withCString { k1 in keyValues[0].1.withCString { v1 in
                keyValues[1].0.withCString { k2 in keyValues[1].1.withCString { v2 in
                keyValues[2].0.withCString { k3 in keyValues[2].1.withCString { v3 in
                keyValues[3].0.withCString { k4 in keyValues[3].1.withCString { v4 in
                keyValues[4].0.withCString { k5 in keyValues[4].1.withCString { v5 in
                    hts_shim_sam_hdr_add_line_5(pointer, t, k1, v1, k2, v2, k3, v3, k4, v4, k5, v5)
                }}}}}}}}}}
            }
        default:
            throw HTSError.invalidArgument(message: "addLine supports 1-5 key-value pairs, got \(keyValues.count)")
        }
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    /// Remove a header line by its identifying tag value.
    ///
    /// - Parameters:
    ///   - type: The two-character record type (e.g. `"SQ"`, `"RG"`).
    ///   - idKey: The identifying tag key (e.g. `"SN"` for `@SQ`), or `nil` to remove the first.
    ///   - idValue: The identifying tag value (e.g. `"chr1"`), or `nil`.
    /// - Throws: ``HTSError/headerWriteFailed`` on failure.
    public func removeLine(type: String, idKey: String? = nil, idValue: String? = nil) throws {
        let ret: Int32
        if let idKey = idKey, let idValue = idValue {
            ret = type.withCString { t in
                idKey.withCString { k in
                    idValue.withCString { v in
                        sam_hdr_remove_line_id(pointer, t, k, v)
                    }
                }
            }
        } else {
            ret = type.withCString { t in
                sam_hdr_remove_line_id(pointer, t, nil, nil)
            }
        }
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    /// Count the number of lines of a given type.
    ///
    /// - Parameter type: The two-character record type (e.g. `"SQ"`, `"RG"`).
    /// - Returns: The number of lines, or -1 on error.
    public func countLines(type: String) -> Int32 {
        type.withCString { sam_hdr_count_lines(pointer, $0) }
    }

    /// Find the value of a tag within a specific header line.
    ///
    /// - Parameters:
    ///   - type: The two-character record type (e.g. `"SQ"`, `"RG"`).
    ///   - idKey: The identifying tag key (e.g. `"SN"`), or `nil` for `@HD`.
    ///   - idValue: The identifying tag value (e.g. `"chr1"`), or `nil` for `@HD`.
    ///   - key: The tag key to retrieve (e.g. `"LN"`).
    /// - Returns: The tag value as a string, or `nil` if not found.
    public func findTag(type: String, idKey: String? = nil, idValue: String? = nil, key: String) -> String? {
        var ks = kstring_t(l: 0, m: 0, s: nil)
        let ret: Int32
        if let idKey = idKey, let idValue = idValue {
            ret = type.withCString { t in
                idKey.withCString { ik in
                    idValue.withCString { iv in
                        key.withCString { k in
                            sam_hdr_find_tag_id(pointer, t, ik, iv, k, &ks)
                        }
                    }
                }
            }
        } else {
            ret = type.withCString { t in
                key.withCString { k in
                    sam_hdr_find_tag_id(pointer, t, nil, nil, k, &ks)
                }
            }
        }
        guard ret == 0, let s = ks.s else {
            free(ks.s)
            return nil
        }
        let result = String(cString: s)
        free(ks.s)
        return result
    }

    /// Add a `@PG` header line with automatic PP chaining.
    ///
    /// - Parameters:
    ///   - name: The program name (ID tag value).
    ///   - keyValues: Additional key-value pairs (e.g. `[("VN","1.0"), ("CL","samtools sort")]`).
    ///     Supports 1-3 pairs.
    /// - Throws: ``HTSError/headerWriteFailed`` on failure.
    public func addProgramGroup(name: String, keyValues: [(String, String)]) throws {
        let ret: Int32
        switch keyValues.count {
        case 1:
            ret = name.withCString { n in
                keyValues[0].0.withCString { k1 in
                    keyValues[0].1.withCString { v1 in
                        hts_shim_sam_hdr_add_pg_1(pointer, n, k1, v1)
                    }
                }
            }
        case 2:
            ret = name.withCString { n in
                keyValues[0].0.withCString { k1 in keyValues[0].1.withCString { v1 in
                keyValues[1].0.withCString { k2 in keyValues[1].1.withCString { v2 in
                    hts_shim_sam_hdr_add_pg_2(pointer, n, k1, v1, k2, v2)
                }}}}
            }
        case 3:
            ret = name.withCString { n in
                keyValues[0].0.withCString { k1 in keyValues[0].1.withCString { v1 in
                keyValues[1].0.withCString { k2 in keyValues[1].1.withCString { v2 in
                keyValues[2].0.withCString { k3 in keyValues[2].1.withCString { v3 in
                    hts_shim_sam_hdr_add_pg_3(pointer, n, k1, v1, k2, v2, k3, v3)
                }}}}}}
            }
        default:
            throw HTSError.invalidArgument(message: "addProgramGroup supports 1-3 key-value pairs, got \(keyValues.count)")
        }
        if ret < 0 { throw HTSError.headerWriteFailed }
    }

    deinit {
        if owned {
            sam_hdr_destroy(pointer)
        }
    }
}
