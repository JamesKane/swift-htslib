import CHtslib
import CHTSlibShims

public struct VCFRecord: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<bcf1_t>

    public init() throws {
        guard let v = bcf_init() else {
            throw HTSError.outOfMemory
        }
        self.pointer = v
    }

    internal init(pointer: UnsafeMutablePointer<bcf1_t>) {
        self.pointer = pointer
    }

    /// Unpack record fields. Call before accessing decoded fields.
    public mutating func unpack(_ level: UnpackLevel = .all) throws {
        let ret = bcf_unpack(pointer, level.rawValue)
        if ret < 0 { throw HTSError.readFailed(code: ret) }
    }

    public enum UnpackLevel: Int32, Sendable {
        case str = 1     // BCF_UN_STR — up through ID
        case flt = 2     // BCF_UN_FLT — up through FILTER
        case info = 4    // BCF_UN_INFO — up through INFO
        case fmt = 8     // BCF_UN_SHR | BCF_UN_FMT — shared + individual
        case all = 15    // BCF_UN_ALL
    }

    // MARK: - Core fields

    public var position: Int64 { pointer.pointee.pos }
    public var contigID: Int32 { pointer.pointee.rid }
    public var quality: Float { pointer.pointee.qual }
    public var nAlleles: Int { Int(pointer.pointee.n_allele) }
    public var nInfo: Int { Int(pointer.pointee.n_info) }
    public var nFormat: Int { Int(pointer.pointee.n_fmt) }
    public var nSamples: Int { Int(pointer.pointee.n_sample) }

    /// Reference length
    public var referenceLength: Int64 { pointer.pointee.rlen }

    /// ID field (requires unpack >= .str)
    public var id: String? {
        guard let s = pointer.pointee.d.id else { return nil }
        return String(cString: s)
    }

    /// Alleles array (requires unpack >= .str)
    public var alleles: [String] {
        let n = Int(pointer.pointee.n_allele)
        guard n > 0, let a = pointer.pointee.d.allele else { return [] }
        return (0..<n).compactMap { i in
            guard let s = a[i] else { return nil }
            return String(cString: s)
        }
    }

    /// FILTER IDs (requires unpack >= .flt)
    public var filterIDs: [Int32] {
        let n = Int(pointer.pointee.d.n_flt)
        guard n > 0, let flt = pointer.pointee.d.flt else { return [] }
        return (0..<n).map { flt[$0] }
    }

    /// Filter names (requires header + unpack >= .flt)
    public func filterNames(header: VCFHeader) -> [String] {
        filterIDs.compactMap { id in
            guard let name = hts_shim_bcf_hdr_int2id(header.pointer, Int32(BCF_DT_ID), Int32(id)) else { return nil }
            return String(cString: name)
        }
    }

    /// Get variant type
    public var variantType: VariantType {
        VariantType(rawValue: bcf_get_variant_types(pointer))
    }

    deinit {
        bcf_destroy(pointer)
    }
}
