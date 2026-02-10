// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

// MARK: - Pileup Types

/// A single alignment entry at a pileup position.
public struct PileupEntry: Sendable {
    /// Position within the query sequence (0-based)
    public let queryPosition: Int32
    /// Number of inserted bases after this position (0 if none)
    public let indel: Int32
    /// Nesting level in the pileup display
    public let level: Int32
    /// True if this position is a deletion in this read
    public let isDeletion: Bool
    /// True if this is the first base of the read
    public let isHead: Bool
    /// True if this is the last base of the read
    public let isTail: Bool
    /// True if this position is a reference skip (N in CIGAR)
    public let isRefSkip: Bool
    /// The base at this position ('*' for deletion, '>' for ref skip)
    public let base: Character
    /// Base quality (Phred-scaled, 0 for deletions/ref skips)
    public let baseQuality: UInt8
    /// Mapping quality of the alignment
    public let mappingQuality: UInt8
    /// True if the read is mapped to the reverse strand
    public let isReverse: Bool
}

/// A column of pileup entries at a single genomic position.
public struct PileupColumn: Sendable {
    /// Reference sequence ID
    public let contigID: Int32
    /// 0-based position on the reference
    public let position: Int64
    /// Alignment entries covering this position
    public let entries: [PileupEntry]

    /// Number of reads covering this position
    public var depth: Int { entries.count }
}

// MARK: - Internal helpers shared with MultiPileup

/// Lookup table: 4-bit BAM sequence encoding -> ASCII character
private let seq_nt16_str: [Character] = [
    "=", "A", "C", "M", "G", "R", "S", "V",
    "T", "W", "Y", "H", "K", "D", "B", "N"
]

/// Context struct passed through the void* data parameter of the pileup callback.
struct PileupCallbackData {
    var file: UnsafeMutablePointer<htsFile>
    var header: UnsafeMutablePointer<sam_hdr_t>
}

/// C-compatible callback that reads the next alignment record.
/// Returns 0 on success, -1 on EOF, < -1 on error.
let pileupReadCallback: @convention(c) (UnsafeMutableRawPointer?, UnsafeMutablePointer<bam1_t>?) -> Int32 = { data, b in
    guard let data = data, let b = b else { return -1 }
    let ctx = data.assumingMemoryBound(to: PileupCallbackData.self)
    let ret = sam_read1(ctx.pointee.file, ctx.pointee.header, b)
    return ret >= 0 ? 0 : ret
}

/// Construct a PileupEntry from a raw bam_pileup1_t value.
func makePileupEntry(from p: bam_pileup1_t) -> PileupEntry {
    let base: Character
    let qual: UInt8
    if p.is_del != 0 || p.is_refskip != 0 {
        base = p.is_del != 0 ? "*" : ">"
        qual = 0
    } else if let seqPtr = hts_shim_bam_get_seq(p.b),
              let qualPtr = hts_shim_bam_get_qual(p.b) {
        let base4bit = hts_shim_bam_seqi(seqPtr, p.qpos)
        base = seq_nt16_str[Int(base4bit)]
        qual = qualPtr[Int(p.qpos)]
    } else {
        base = "N"
        qual = 0
    }
    return PileupEntry(
        queryPosition: p.qpos,
        indel: Int32(p.indel),
        level: Int32(p.level),
        isDeletion: p.is_del != 0,
        isHead: p.is_head != 0,
        isTail: p.is_tail != 0,
        isRefSkip: p.is_refskip != 0,
        base: base,
        baseQuality: qual,
        mappingQuality: p.b.pointee.core.qual,
        isReverse: hts_shim_bam_is_rev(p.b) != 0
    )
}

// MARK: - PileupIterator

/// Iterates pileup columns over a SAM/BAM/CRAM file.
///
/// Usage:
/// ```
/// let pileup = PileupIterator(file: file.pointer, header: header.pointer)
/// while let column = pileup.next() {
///     print("pos \(column.position): depth \(column.depth)")
/// }
/// ```
public final class PileupIterator {
    private var plp: OpaquePointer?
    private var context: UnsafeMutablePointer<PileupCallbackData>

    /// Create a pileup iterator over all records in the file.
    public init(file: UnsafeMutablePointer<htsFile>, header: UnsafeMutablePointer<sam_hdr_t>) {
        context = .allocate(capacity: 1)
        context.initialize(to: PileupCallbackData(file: file, header: header))
        plp = bam_plp_init(pileupReadCallback, context)
    }

    /// Set the maximum number of reads to pile up at any position.
    public func setMaxDepth(_ maxcnt: Int32) {
        guard let plp = plp else { return }
        bam_plp_set_maxcnt(plp, maxcnt)
    }

    /// Reset the pileup iterator.
    public func reset() {
        guard let plp = plp else { return }
        bam_plp_reset(plp)
    }

    /// Get the next pileup column.
    public func next() -> PileupColumn? {
        guard let plp = plp else { return nil }
        var tid: Int32 = 0
        var pos: Int64 = 0
        var nPlp: Int32 = 0
        guard let entries = bam_plp64_auto(plp, &tid, &pos, &nPlp) else { return nil }
        if nPlp <= 0 { return nil }

        var result: [PileupEntry] = []
        result.reserveCapacity(Int(nPlp))
        for i in 0..<Int(nPlp) {
            result.append(makePileupEntry(from: entries[i]))
        }
        return PileupColumn(contigID: tid, position: pos, entries: result)
    }

    deinit {
        if let plp = plp { bam_plp_destroy(plp) }
        context.deinitialize(count: 1)
        context.deallocate()
    }
}
