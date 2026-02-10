import CHtslib
import CHTSlibShims

public struct CIGAROperation: Sendable, Hashable {
    public let rawValue: UInt32

    public init(rawValue: UInt32) { self.rawValue = rawValue }

    public var op: Op {
        Op(rawValue: UInt8(hts_shim_bam_cigar_op(rawValue))) ?? .match
    }

    public var length: UInt32 {
        hts_shim_bam_cigar_oplen(rawValue)
    }

    public var character: Character {
        Character(UnicodeScalar(UInt8(bitPattern: Int8(hts_shim_bam_cigar_opchr(rawValue)))))
    }

    /// Whether this operation consumes the query sequence
    public var consumesQuery: Bool {
        hts_shim_bam_cigar_type(UInt32(op.rawValue)) & 1 != 0
    }

    /// Whether this operation consumes the reference
    public var consumesReference: Bool {
        hts_shim_bam_cigar_type(UInt32(op.rawValue)) & 2 != 0
    }

    public static func make(length: UInt32, op: Op) -> CIGAROperation {
        CIGAROperation(rawValue: hts_shim_bam_cigar_gen(length, UInt32(op.rawValue)))
    }

    public enum Op: UInt8, Sendable, Hashable, CaseIterable {
        case match = 0        // M
        case insertion = 1    // I
        case deletion = 2     // D
        case refSkip = 3      // N
        case softClip = 4     // S
        case hardClip = 5     // H
        case padding = 6      // P
        case seqMatch = 7     // =
        case seqMismatch = 8  // X
        case back = 9         // B
    }
}
