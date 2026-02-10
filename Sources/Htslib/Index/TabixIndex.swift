import CHtslib
import CHTSlibShims

/// A tabix index for BGZF-compressed tab-delimited files (VCF, BED, GFF, etc.).
///
/// Tabix indexes enable fast region queries on sorted, BGZF-compressed files.
/// This is a move-only type that destroys the index on deinitialization.
public struct TabixIndex: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<tbx_t>

    /// Load a tabix index for the given file.
    ///
    /// - Parameter path: Path to the BGZF-compressed file (the `.tbi` index is located automatically).
    /// - Throws: ``HTSError/indexLoadFailed(path:)`` if the index cannot be loaded.
    public init(path: String) throws {
        guard let tbx = path.withCString({ tbx_index_load($0) }) else {
            throw HTSError.indexLoadFailed(path: path)
        }
        self.pointer = tbx
    }

    /// The names of all sequences in the index.
    public var sequenceNames: [String] {
        var n: Int32 = 0
        guard let names = tbx_seqnames(pointer, &n) else { return [] }
        defer { free(names) }
        return (0..<Int(n)).compactMap { i in
            guard let s = names[i] else { return nil }
            return String(cString: s)
        }
    }

    /// Build a tabix index for a BGZF-compressed file.
    ///
    /// - Parameters:
    ///   - path: Path to the BGZF-compressed file.
    ///   - preset: The file format preset (determines column layout).
    ///   - minShift: Minimum bit-shift for the index (0 for default).
    /// - Throws: ``HTSError/indexBuildFailed(path:code:)`` on failure.
    public static func build(path: String, preset: Preset = .vcf, minShift: Int32 = 0) throws {
        var conf = preset.configuration
        let ret = path.withCString { tbx_index_build($0, minShift, &conf) }
        if ret < 0 {
            throw HTSError.indexBuildFailed(path: path, code: ret)
        }
    }

    /// Predefined column configurations for common file formats.
    public enum Preset: Sendable {
        /// GFF/GTF format.
        case gff
        /// BED format.
        case bed
        /// SAM format.
        case sam
        /// VCF format.
        case vcf

        var configuration: tbx_conf_t {
            switch self {
            case .gff: return tbx_conf_gff
            case .bed: return tbx_conf_bed
            case .sam: return tbx_conf_sam
            case .vcf: return tbx_conf_vcf
            }
        }
    }

    // MARK: - Query

    /// Create an iterator for records overlapping a region string.
    ///
    /// - Parameters:
    ///   - region: A region string (e.g. `"chr1:1000-2000"`).
    ///   - file: The open HTSFile for the tabix-indexed file.
    /// - Returns: A ``TabixIterator`` for the matching records.
    /// - Throws: ``HTSError/regionParseFailed(region:)`` if the region is invalid.
    public func query(region: String, file: borrowing HTSFile) throws -> TabixIterator {
        guard let iter = region.withCString({ hts_shim_tbx_itr_querys(pointer, $0) }) else {
            throw HTSError.regionParseFailed(region: region)
        }
        return TabixIterator(file: file.pointer, tbx: pointer, iter: iter)
    }

    /// Create an iterator for records overlapping a numeric region.
    ///
    /// - Parameters:
    ///   - tid: The sequence ID.
    ///   - start: The 0-based start position.
    ///   - end: The 0-based exclusive end position.
    ///   - file: The open HTSFile for the tabix-indexed file.
    /// - Returns: A ``TabixIterator`` for the matching records.
    /// - Throws: ``HTSError/seekFailed`` if the iterator cannot be created.
    public func query(tid: Int32, start: Int64, end: Int64, file: borrowing HTSFile) throws -> TabixIterator {
        guard let iter = hts_shim_tbx_itr_queryi(pointer, tid, start, end) else {
            throw HTSError.seekFailed
        }
        return TabixIterator(file: file.pointer, tbx: pointer, iter: iter)
    }

    deinit {
        tbx_destroy(pointer)
    }
}
