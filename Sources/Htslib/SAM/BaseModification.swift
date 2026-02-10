// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

// MARK: - BaseModification

/// A single base modification at a sequence position.
public struct BaseModification: Sendable {
    /// The modification code: positive for single-char codes (e.g., 'm' for 5mC),
    /// negative for ChEBI numbers (e.g., -21839).
    public let modifiedBase: Int32
    /// The canonical base from the MM tag (A, C, G, T, or N)
    public let canonicalBase: Int32
    /// Strand: 0 for +, 1 for -
    public let strand: Int32
    /// Quality (256 * probability), or -1 if unknown
    public let quality: Int32

    public init(modifiedBase: Int32, canonicalBase: Int32, strand: Int32, quality: Int32) {
        self.modifiedBase = modifiedBase
        self.canonicalBase = canonicalBase
        self.strand = strand
        self.quality = quality
    }

    init(from mod: hts_base_mod) {
        self.modifiedBase = Int32(mod.modified_base)
        self.canonicalBase = Int32(mod.canonical_base)
        self.strand = Int32(mod.strand)
        self.quality = Int32(mod.qual)
    }

    /// The canonical base as a Character
    public var canonicalBaseCharacter: Character {
        Character(UnicodeScalar(UInt8(canonicalBase & 0xFF)))
    }

    /// Whether the quality is known
    public var hasQuality: Bool {
        quality >= 0
    }

    /// Quality as a probability (0.0 to 1.0), or nil if unknown
    public var probability: Double? {
        guard quality >= 0 else { return nil }
        return Double(quality) / 256.0
    }
}

// MARK: - BaseModificationState

/// Manages base modification parsing state for BAM records with MM/ML tags.
///
/// Usage:
/// ```
/// let state = try BaseModificationState()
/// try state.parse(record: record)
/// while let (mods, pos) = state.nextModification(record: record) {
///     print("pos \(pos): \(mods.count) modifications")
/// }
/// ```
public final class BaseModificationState {
    private var state: OpaquePointer?

    /// Allocate a new base modification state.
    public init() throws {
        guard let s = hts_base_mod_state_alloc() else {
            throw HTSError.outOfMemory
        }
        self.state = s
    }

    /// Parse base modifications from a BAM record's MM and ML tags.
    /// Resets the iterator to the first sequence base.
    public func parse(record: borrowing BAMRecord) throws {
        let ret = bam_parse_basemod(record.pointer, state)
        if ret < 0 { throw HTSError.parseFailed(message: "Failed to parse base modifications") }
    }

    /// Get modifications at the next sequence position (sequential iteration).
    /// Call repeatedly to walk through every position in the query sequence.
    /// Returns an empty array if no modifications at this position, or nil on failure.
    public func modificationsAtNextPosition(record: borrowing BAMRecord, maxMods: Int = 256) -> [BaseModification]? {
        var mods = [hts_base_mod](repeating: hts_base_mod(), count: maxMods)
        let n = mods.withUnsafeMutableBufferPointer { buf in
            bam_mods_at_next_pos(record.pointer, state, buf.baseAddress, Int32(maxMods))
        }
        if n < 0 { return nil }
        return (0..<Int(n)).map { BaseModification(from: mods[$0]) }
    }

    /// Skip to the next position that has modifications.
    /// Returns the modifications and position, or nil when done.
    public func nextModification(record: borrowing BAMRecord, maxMods: Int = 256) -> (modifications: [BaseModification], position: Int32)? {
        var mods = [hts_base_mod](repeating: hts_base_mod(), count: maxMods)
        var pos: Int32 = 0
        let n = mods.withUnsafeMutableBufferPointer { buf in
            bam_next_basemod(record.pointer, state, buf.baseAddress, Int32(maxMods), &pos)
        }
        if n <= 0 { return nil }
        return (modifications: (0..<Int(n)).map { BaseModification(from: mods[$0]) }, position: pos)
    }

    /// Get modifications at a specific query position.
    /// Must be called with ascending qpos values (designed for pileup).
    public func modificationsAtPosition(record: borrowing BAMRecord, queryPosition: Int32, maxMods: Int = 256) -> [BaseModification]? {
        var mods = [hts_base_mod](repeating: hts_base_mod(), count: maxMods)
        let n = mods.withUnsafeMutableBufferPointer { buf in
            bam_mods_at_qpos(record.pointer, queryPosition, state, buf.baseAddress, Int32(maxMods))
        }
        if n < 0 { return nil }
        return (0..<Int(n)).map { BaseModification(from: mods[$0]) }
    }

    /// Get the list of recorded modification type codes.
    /// Positive values are character codes (e.g., 'm' for 5mC),
    /// negative values are ChEBI numbers.
    public func recordedModifications() -> [Int32] {
        var ntype: Int32 = 0
        guard let types = bam_mods_recorded(state, &ntype) else { return [] }
        return (0..<Int(ntype)).map { types[$0] }
    }

    deinit {
        if let state = state {
            hts_base_mod_state_free(state)
        }
    }
}
