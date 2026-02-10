import CHtslib
import CHTSlibShims

/// A single alignment record from a SAM/BAM/CRAM file.
///
/// `BAMRecord` is a move-only type (`~Copyable`) that owns the underlying `bam1_t`
/// allocation and frees it on deinitialization. Access core alignment fields directly,
/// or use ``cigar``, ``sequence``, ``qualities``, and ``auxiliaryData`` for structured
/// access to variable-length data.
public struct BAMRecord: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<bam1_t>

    /// Allocate an empty BAM record.
    ///
    /// - Throws: ``HTSError/outOfMemory`` if allocation fails.
    public init() throws {
        guard let b = bam_init1() else {
            throw HTSError.outOfMemory
        }
        self.pointer = b
    }

    internal init(pointer: UnsafeMutablePointer<bam1_t>) {
        self.pointer = pointer
    }

    // MARK: - Core fields

    /// 0-based leftmost mapping position on the reference.
    public var position: Int64 { pointer.pointee.core.pos }
    /// 0-based exclusive end position on the reference (computed from CIGAR).
    public var endPosition: Int64 { bam_endpos(pointer) }
    /// Reference sequence ID (index into the header's target list), or -1 if unmapped.
    public var contigID: Int32 { pointer.pointee.core.tid }
    /// Mate's reference sequence ID, or -1 if unavailable.
    public var mateContigID: Int32 { pointer.pointee.core.mtid }
    /// 0-based leftmost mapping position of the mate.
    public var matePosition: Int64 { pointer.pointee.core.mpos }
    /// Observed template length (TLEN field).
    public var insertSize: Int64 { pointer.pointee.core.isize }
    /// Phred-scaled mapping quality (255 if unavailable).
    public var mappingQuality: UInt8 { pointer.pointee.core.qual }
    /// The SAM FLAG field as an ``AlignmentFlag`` option set.
    public var flag: AlignmentFlag { AlignmentFlag(rawValue: pointer.pointee.core.flag) }
    /// Number of CIGAR operations.
    public var cigarCount: UInt32 { pointer.pointee.core.n_cigar }
    /// Length of the query sequence in bases.
    public var sequenceLength: Int32 { pointer.pointee.core.l_qseq }

    // MARK: - Computed properties via shims

    /// The query template name (QNAME).
    public var queryName: String {
        String(cString: hts_shim_bam_get_qname(pointer))
    }

    /// Whether the read is mapped to the reverse strand.
    public var isReverse: Bool {
        hts_shim_bam_is_rev(pointer) != 0
    }

    /// Whether the mate is mapped to the reverse strand.
    public var isMateReverse: Bool {
        hts_shim_bam_is_mrev(pointer) != 0
    }

    /// Whether the read is unmapped (FLAG bit 0x4).
    public var isUnmapped: Bool {
        flag.contains(.unmapped)
    }

    /// Whether this is a secondary alignment (FLAG bit 0x100).
    public var isSecondary: Bool {
        flag.contains(.secondary)
    }

    /// Whether this is a supplementary alignment (FLAG bit 0x800).
    public var isSupplementary: Bool {
        flag.contains(.supplementary)
    }

    /// Whether this read is a PCR or optical duplicate (FLAG bit 0x400).
    public var isDuplicate: Bool {
        flag.contains(.duplicate)
    }

    // MARK: - CIGAR

    /// The CIGAR operations for this alignment as a random-access collection.
    public var cigar: CIGARSequence {
        CIGARSequence(record: pointer)
    }

    // MARK: - Sequence

    /// The query sequence as a random-access collection of base characters.
    public var sequence: BAMSequence {
        BAMSequence(record: pointer)
    }

    // MARK: - Qualities

    /// The per-base Phred quality scores as a random-access collection.
    public var qualities: BAMQualities {
        BAMQualities(record: pointer)
    }

    // MARK: - Auxiliary data

    /// Accessor for auxiliary (tag) data attached to this record.
    public var auxiliaryData: AuxiliaryData {
        AuxiliaryData(record: pointer)
    }

    deinit {
        bam_destroy1(pointer)
    }
}

// MARK: - CIGARSequence

/// A random-access view of the CIGAR operations in a BAM record.
///
/// Each element is a ``CIGAROperation`` encoding both the operation type and length.
public struct CIGARSequence: RandomAccessCollection, @unchecked Sendable {
    nonisolated(unsafe) private let cigarPointer: UnsafePointer<UInt32>
    /// The number of CIGAR operations.
    public let count: Int

    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    internal init(record: UnsafePointer<bam1_t>) {
        self.cigarPointer = UnsafePointer(hts_shim_bam_get_cigar(UnsafeMutablePointer(mutating: record)))
        self.count = Int(record.pointee.core.n_cigar)
    }

    public subscript(position: Int) -> CIGAROperation {
        precondition(position >= 0 && position < count)
        return CIGAROperation(rawValue: cigarPointer[position])
    }
}

// MARK: - BAMSequence

/// A random-access view of the query sequence in a BAM record.
///
/// Each element is a `Character` representing a nucleotide base (A, C, G, T, N, etc.)
/// decoded from the 4-bit BAM encoding.
public struct BAMSequence: RandomAccessCollection, @unchecked Sendable {
    nonisolated(unsafe) private let seqPointer: UnsafePointer<UInt8>
    /// The number of bases in the sequence.
    public let count: Int

    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    /// Lookup table: 4-bit encoding -> ASCII character
    private static let bases: [Character] = [
        "=", "A", "C", "M", "G", "R", "S", "V",
        "T", "W", "Y", "H", "K", "D", "B", "N"
    ]

    internal init(record: UnsafePointer<bam1_t>) {
        self.seqPointer = UnsafePointer(hts_shim_bam_get_seq(UnsafeMutablePointer(mutating: record)))
        self.count = Int(record.pointee.core.l_qseq)
    }

    public subscript(position: Int) -> Character {
        precondition(position >= 0 && position < count)
        let base = hts_shim_bam_seqi(UnsafeMutablePointer(mutating: seqPointer), Int32(position))
        return BAMSequence.bases[Int(base)]
    }

    /// The full sequence as a `String`.
    public var string: String {
        String(self.map { $0 })
    }
}

// MARK: - BAMQualities

/// A random-access view of the per-base Phred quality scores in a BAM record.
///
/// Each element is a `UInt8` Phred quality value. A value of 255 indicates
/// that the quality is not available.
public struct BAMQualities: RandomAccessCollection, @unchecked Sendable {
    nonisolated(unsafe) private let qualPointer: UnsafePointer<UInt8>
    /// The number of quality values (equal to the sequence length).
    public let count: Int

    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    internal init(record: UnsafePointer<bam1_t>) {
        self.qualPointer = UnsafePointer(hts_shim_bam_get_qual(UnsafeMutablePointer(mutating: record)))
        self.count = Int(record.pointee.core.l_qseq)
    }

    public subscript(position: Int) -> UInt8 {
        precondition(position >= 0 && position < count)
        return qualPointer[position]
    }
}
