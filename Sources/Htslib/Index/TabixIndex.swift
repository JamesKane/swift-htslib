import CHtslib
import CHTSlibShims

public struct TabixIndex: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<tbx_t>

    public init(path: String) throws {
        guard let tbx = path.withCString({ tbx_index_load($0) }) else {
            throw HTSError.indexLoadFailed(path: path)
        }
        self.pointer = tbx
    }

    public var sequenceNames: [String] {
        var n: Int32 = 0
        guard let names = tbx_seqnames(pointer, &n) else { return [] }
        defer { free(names) }
        return (0..<Int(n)).compactMap { i in
            guard let s = names[i] else { return nil }
            return String(cString: s)
        }
    }

    /// Build a tabix index
    public static func build(path: String, preset: Preset = .vcf, minShift: Int32 = 0) throws {
        var conf = preset.configuration
        let ret = path.withCString { tbx_index_build($0, minShift, &conf) }
        if ret < 0 {
            throw HTSError.indexBuildFailed(path: path, code: ret)
        }
    }

    public enum Preset: Sendable {
        case gff, bed, sam, vcf

        var configuration: tbx_conf_t {
            switch self {
            case .gff: return tbx_conf_gff
            case .bed: return tbx_conf_bed
            case .sam: return tbx_conf_sam
            case .vcf: return tbx_conf_vcf
            }
        }
    }

    deinit {
        tbx_destroy(pointer)
    }
}
