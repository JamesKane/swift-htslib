import CHtslib
import CHTSlibShims

public struct BAMRecord: ~Copyable, @unchecked Sendable {
    @usableFromInline
    nonisolated(unsafe) var pointer: UnsafeMutablePointer<bam1_t>

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

    public var position: Int64 { pointer.pointee.core.pos }
    public var endPosition: Int64 { bam_endpos(pointer) }
    public var contigID: Int32 { pointer.pointee.core.tid }
    public var mateContigID: Int32 { pointer.pointee.core.mtid }
    public var matePosition: Int64 { pointer.pointee.core.mpos }
    public var insertSize: Int64 { pointer.pointee.core.isize }
    public var mappingQuality: UInt8 { pointer.pointee.core.qual }
    public var flag: AlignmentFlag { AlignmentFlag(rawValue: pointer.pointee.core.flag) }
    public var cigarCount: UInt32 { pointer.pointee.core.n_cigar }
    public var sequenceLength: Int32 { pointer.pointee.core.l_qseq }

    // MARK: - Computed properties via shims

    public var queryName: String {
        String(cString: hts_shim_bam_get_qname(pointer))
    }

    public var isReverse: Bool {
        hts_shim_bam_is_rev(pointer) != 0
    }

    public var isMateReverse: Bool {
        hts_shim_bam_is_mrev(pointer) != 0
    }

    public var isUnmapped: Bool {
        flag.contains(.unmapped)
    }

    public var isSecondary: Bool {
        flag.contains(.secondary)
    }

    public var isSupplementary: Bool {
        flag.contains(.supplementary)
    }

    public var isDuplicate: Bool {
        flag.contains(.duplicate)
    }

    // MARK: - CIGAR

    public var cigar: CIGARSequence {
        CIGARSequence(record: pointer)
    }

    // MARK: - Sequence

    public var sequence: BAMSequence {
        BAMSequence(record: pointer)
    }

    // MARK: - Qualities

    public var qualities: BAMQualities {
        BAMQualities(record: pointer)
    }

    // MARK: - Auxiliary data

    public var auxiliaryData: AuxiliaryData {
        AuxiliaryData(record: pointer)
    }

    deinit {
        bam_destroy1(pointer)
    }
}

// MARK: - CIGARSequence

public struct CIGARSequence: RandomAccessCollection, @unchecked Sendable {
    nonisolated(unsafe) private let cigarPointer: UnsafePointer<UInt32>
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

public struct BAMSequence: RandomAccessCollection, @unchecked Sendable {
    nonisolated(unsafe) private let seqPointer: UnsafePointer<UInt8>
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

    public var string: String {
        String(self.map { $0 })
    }
}

// MARK: - BAMQualities

public struct BAMQualities: RandomAccessCollection, @unchecked Sendable {
    nonisolated(unsafe) private let qualPointer: UnsafePointer<UInt8>
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
