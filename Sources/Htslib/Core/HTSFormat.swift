import CHtslib

public enum HTSFileFormat: Sendable {
    case sam, bam, cram
    case vcf, bcf
    case bai, crai, csi, gzi, tbi
    case bed
    case fasta, fastq
    case fai, fqi
    case emptyFormat
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

public enum HTSFormatCategory: Sendable {
    case unknownCategory
    case sequenceData
    case variantData
    case indexFile
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
