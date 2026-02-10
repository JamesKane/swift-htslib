// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// CRAM-specific format options for configuring encoding and decoding.
///
/// Use with ``HTSFile/setOption(_:intValue:)`` and ``HTSFile/setOption(_:stringValue:)``
/// to configure CRAM file handling.
public enum CRAMOption: Sendable {
    /// Decode MD and NM tags from CRAM (int: 0/1).
    case decodeMD
    /// Number of sequences per slice (int).
    case seqsPerSlice
    /// Number of slices per container (int).
    case slicesPerContainer
    /// CRAM format version (int, e.g. major*256+minor).
    case version
    /// Embed reference sequence in CRAM (int: 0/1).
    case embedRef
    /// Ignore MD5 checksums (int: 0/1).
    case ignoreMD5
    /// Path to reference FASTA file (string).
    case reference
    /// Allow multiple reference sequences per slice (int: 0/1).
    case multiSeqPerSlice
    /// Encode without reference (int: 0/1).
    case noRef
    /// Use bzip2 compression (int: 0/1).
    case useBzip2
    /// Use LZMA compression (int: 0/1).
    case useLzma
    /// Use rANS compression (int: 0/1).
    case useRans
    /// Use name tokenizer compression (int: 0/1).
    case useTokenizer
    /// Use fqzcomp compression (int: 0/1).
    case useFqzcomp
    /// Use arithmetic coder (int: 0/1).
    case useArith
    /// Bitmask of required SAM fields (int: SAM_* flags).
    case requiredFields
    /// Enable lossy read name compression (int: 0/1).
    case lossyNames
    /// Number of bases per slice (int).
    case basesPerSlice
    /// Store MD tag in CRAM (int: 0/1).
    case storeMD
    /// Store NM tag in CRAM (int: 0/1).
    case storeNM
    /// Force position delta for AP, even on non-position sorted data (int: 0/1).
    case posDelta

    internal var rawValue: hts_fmt_option {
        switch self {
        case .decodeMD: return CRAM_OPT_DECODE_MD
        case .seqsPerSlice: return CRAM_OPT_SEQS_PER_SLICE
        case .slicesPerContainer: return CRAM_OPT_SLICES_PER_CONTAINER
        case .version: return CRAM_OPT_VERSION
        case .embedRef: return CRAM_OPT_EMBED_REF
        case .ignoreMD5: return CRAM_OPT_IGNORE_MD5
        case .reference: return CRAM_OPT_REFERENCE
        case .multiSeqPerSlice: return CRAM_OPT_MULTI_SEQ_PER_SLICE
        case .noRef: return CRAM_OPT_NO_REF
        case .useBzip2: return CRAM_OPT_USE_BZIP2
        case .useLzma: return CRAM_OPT_USE_LZMA
        case .useRans: return CRAM_OPT_USE_RANS
        case .requiredFields: return CRAM_OPT_REQUIRED_FIELDS
        case .lossyNames: return CRAM_OPT_LOSSY_NAMES
        case .basesPerSlice: return CRAM_OPT_BASES_PER_SLICE
        case .storeMD: return CRAM_OPT_STORE_MD
        case .storeNM: return CRAM_OPT_STORE_NM
        case .useTokenizer: return CRAM_OPT_USE_TOK
        case .useFqzcomp: return CRAM_OPT_USE_FQZ
        case .useArith: return CRAM_OPT_USE_ARITH
        case .posDelta: return CRAM_OPT_POS_DELTA
        }
    }
}

/// Compression profile presets for CRAM and other formats.
public enum CompressionProfile: Sendable {
    /// Fast compression (larger files, faster encoding).
    case fast
    /// Normal compression (balanced speed and size).
    case normal
    /// Small compression (smaller files, slower encoding).
    case small
    /// Archive compression (smallest files, slowest encoding).
    case archive

    internal var rawValue: hts_profile_option {
        switch self {
        case .fast: return HTS_PROFILE_FAST
        case .normal: return HTS_PROFILE_NORMAL
        case .small: return HTS_PROFILE_SMALL
        case .archive: return HTS_PROFILE_ARCHIVE
        }
    }
}
