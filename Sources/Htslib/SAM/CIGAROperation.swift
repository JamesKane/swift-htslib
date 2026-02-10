// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// A single CIGAR operation encoding both an operation type and a run length.
///
/// The raw 32-bit value packs the operation in the low 4 bits and the length
/// in the upper 28 bits, following the BAM specification.
public struct CIGAROperation: Sendable, Hashable {
    /// The raw 32-bit packed CIGAR value.
    public let rawValue: UInt32

    /// Create a CIGAR operation from a raw 32-bit packed value.
    public init(rawValue: UInt32) { self.rawValue = rawValue }

    /// The operation type.
    public var op: Op {
        Op(rawValue: UInt8(hts_shim_bam_cigar_op(rawValue))) ?? .match
    }

    /// The number of bases this operation spans.
    public var length: UInt32 {
        hts_shim_bam_cigar_oplen(rawValue)
    }

    /// The single-character representation of the operation (M, I, D, N, S, H, P, =, X, B).
    public var character: Character {
        Character(UnicodeScalar(UInt8(bitPattern: Int8(hts_shim_bam_cigar_opchr(rawValue)))))
    }

    /// Whether this operation consumes the query sequence.
    public var consumesQuery: Bool {
        hts_shim_bam_cigar_type(UInt32(op.rawValue)) & 1 != 0
    }

    /// Whether this operation consumes the reference sequence.
    public var consumesReference: Bool {
        hts_shim_bam_cigar_type(UInt32(op.rawValue)) & 2 != 0
    }

    /// Create a CIGAR operation from an operation type and length.
    ///
    /// - Parameters:
    ///   - length: Number of bases.
    ///   - op: The operation type.
    /// - Returns: A packed ``CIGAROperation``.
    public static func make(length: UInt32, op: Op) -> CIGAROperation {
        CIGAROperation(rawValue: hts_shim_bam_cigar_gen(length, UInt32(op.rawValue)))
    }

    /// CIGAR operation types as defined in the SAM specification.
    public enum Op: UInt8, Sendable, Hashable, CaseIterable {
        /// Alignment match or mismatch (M).
        case match = 0
        /// Insertion to the reference (I).
        case insertion = 1
        /// Deletion from the reference (D).
        case deletion = 2
        /// Skipped region from the reference, e.g. intron (N).
        case refSkip = 3
        /// Soft clipping — bases present in SEQ but not aligned (S).
        case softClip = 4
        /// Hard clipping — bases not present in SEQ (H).
        case hardClip = 5
        /// Padding — silent deletion from padded reference (P).
        case padding = 6
        /// Sequence match (=).
        case seqMatch = 7
        /// Sequence mismatch (X).
        case seqMismatch = 8
        /// Backwards operation (B) — used in some CIGAR extensions.
        case back = 9
    }
}
