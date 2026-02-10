import CHtslib

/// Bitwise flags describing properties of a BAM alignment record.
///
/// Conforms to `OptionSet`, so flags can be combined and tested with set operations.
/// Flag values correspond to the SAM specification FLAG field (SAM v1 Section 1.4).
public struct AlignmentFlag: OptionSet, Sendable, Hashable {
    public let rawValue: UInt16
    public init(rawValue: UInt16) { self.rawValue = rawValue }

    /// The read is part of a paired-end experiment (0x1).
    public static let paired           = AlignmentFlag(rawValue: 0x1)     // BAM_FPAIRED
    /// Both reads in the pair are mapped in a proper pair (0x2).
    public static let properPair       = AlignmentFlag(rawValue: 0x2)     // BAM_FPROPER_PAIR
    /// This read is unmapped (0x4).
    public static let unmapped         = AlignmentFlag(rawValue: 0x4)     // BAM_FUNMAP
    /// The mate is unmapped (0x8).
    public static let mateUnmapped     = AlignmentFlag(rawValue: 0x8)     // BAM_FMUNMAP
    /// This read is mapped to the reverse strand (0x10).
    public static let reverse          = AlignmentFlag(rawValue: 0x10)    // BAM_FREVERSE
    /// The mate is mapped to the reverse strand (0x20).
    public static let mateReverse      = AlignmentFlag(rawValue: 0x20)    // BAM_FMREVERSE
    /// This is read 1 in a pair (0x40).
    public static let read1            = AlignmentFlag(rawValue: 0x40)    // BAM_FREAD1
    /// This is read 2 in a pair (0x80).
    public static let read2            = AlignmentFlag(rawValue: 0x80)    // BAM_FREAD2
    /// This is a secondary alignment (0x100).
    public static let secondary        = AlignmentFlag(rawValue: 0x100)   // BAM_FSECONDARY
    /// The read failed platform/vendor quality checks (0x200).
    public static let failedQC         = AlignmentFlag(rawValue: 0x200)   // BAM_FQCFAIL
    /// The read is a PCR or optical duplicate (0x400).
    public static let duplicate        = AlignmentFlag(rawValue: 0x400)   // BAM_FDUP
    /// This is a supplementary alignment (0x800).
    public static let supplementary    = AlignmentFlag(rawValue: 0x800)   // BAM_FSUPPLEMENTARY
}
