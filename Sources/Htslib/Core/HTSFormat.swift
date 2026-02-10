// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// The exact file format detected by htslib.
public enum HTSFileFormat: Sendable {
    /// SAM text alignment format.
    case sam
    /// BAM binary alignment format.
    case bam
    /// CRAM compressed alignment format.
    case cram
    /// VCF text variant call format.
    case vcf
    /// BCF binary variant call format.
    case bcf
    /// BAM index (.bai).
    case bai
    /// CRAM index (.crai).
    case crai
    /// Coordinate-sorted index (.csi).
    case csi
    /// BGZF index (.gzi).
    case gzi
    /// Tabix index (.tbi).
    case tbi
    /// BED region format.
    case bed
    /// FASTA sequence format.
    case fasta
    /// FASTQ sequence format.
    case fastq
    /// FASTA index (.fai).
    case fai
    /// FASTQ index (.fqi).
    case fqi
    /// Empty/unset format.
    case emptyFormat
    /// Unrecognized format.
    case unknown

    init(from cFormat: htsExactFormat) {
        switch cFormat {
        case CHtslib.sam: self = .sam
        case CHtslib.bam: self = .bam
        case CHtslib.cram: self = .cram
        case CHtslib.vcf: self = .vcf
        case CHtslib.bcf: self = .bcf
        case CHtslib.bai: self = .bai
        case CHtslib.crai: self = .crai
        case CHtslib.csi: self = .csi
        case CHtslib.gzi: self = .gzi
        case CHtslib.tbi: self = .tbi
        case CHtslib.bed: self = .bed
        case CHtslib.fasta_format: self = .fasta
        case CHtslib.fastq_format: self = .fastq
        case CHtslib.fai_format: self = .fai
        case CHtslib.fqi_format: self = .fqi
        case CHtslib.empty_format: self = .emptyFormat
        default: self = .unknown
        }
    }
}

/// The high-level category of an HTS file format.
public enum HTSFormatCategory: Sendable {
    /// Unrecognized category.
    case unknownCategory
    /// Sequence data (SAM/BAM/CRAM/FASTA/FASTQ).
    case sequenceData
    /// Variant data (VCF/BCF).
    case variantData
    /// Index file (BAI/CSI/TBI/CRAI).
    case indexFile
    /// Region list (BED).
    case regionList

    init(from cCategory: htsFormatCategory) {
        switch cCategory {
        case CHtslib.sequence_data: self = .sequenceData
        case CHtslib.variant_data: self = .variantData
        case CHtslib.index_file: self = .indexFile
        case CHtslib.region_list: self = .regionList
        default: self = .unknownCategory
        }
    }
}
