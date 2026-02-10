import CHtslib

public struct AlignmentFlag: OptionSet, Sendable, Hashable {
    public let rawValue: UInt16
    public init(rawValue: UInt16) { self.rawValue = rawValue }

    public static let paired           = AlignmentFlag(rawValue: 0x1)     // BAM_FPAIRED
    public static let properPair       = AlignmentFlag(rawValue: 0x2)     // BAM_FPROPER_PAIR
    public static let unmapped         = AlignmentFlag(rawValue: 0x4)     // BAM_FUNMAP
    public static let mateUnmapped     = AlignmentFlag(rawValue: 0x8)     // BAM_FMUNMAP
    public static let reverse          = AlignmentFlag(rawValue: 0x10)    // BAM_FREVERSE
    public static let mateReverse      = AlignmentFlag(rawValue: 0x20)    // BAM_FMREVERSE
    public static let read1            = AlignmentFlag(rawValue: 0x40)    // BAM_FREAD1
    public static let read2            = AlignmentFlag(rawValue: 0x80)    // BAM_FREAD2
    public static let secondary        = AlignmentFlag(rawValue: 0x100)   // BAM_FSECONDARY
    public static let failedQC         = AlignmentFlag(rawValue: 0x200)   // BAM_FQCFAIL
    public static let duplicate        = AlignmentFlag(rawValue: 0x400)   // BAM_FDUP
    public static let supplementary    = AlignmentFlag(rawValue: 0x800)   // BAM_FSUPPLEMENTARY
}
