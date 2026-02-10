import Testing
import CHTSlibShims
@testable import Htslib

@Suite("Genotype")
struct GenotypeTests {
    @Test func decodeGenotypes() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        try record.unpack(.all)

        let gts = record.genotypes(header: header)
        #expect(gts != nil)
        #expect(gts!.count == 2)

        // Sample A: 0/1
        let gt0 = gts![0]
        #expect(gt0.ploidy == 2)
        #expect(gt0.alleles[0] == 0)
        #expect(gt0.alleles[1] == 1)
        #expect(gt0.isHeterozygous)
        #expect(!gt0.isHomozygous)
        #expect(!gt0.isMissing)

        // Sample B: 0/1
        let gt1 = gts![1]
        #expect(gt1.isHeterozygous)
    }

    @Test func genotypeShimFunctions() {
        let phased = hts_shim_bcf_gt_phased(1)
        let isPhasedResult = hts_shim_bcf_gt_is_phased(phased) != 0
        #expect(isPhasedResult)
        #expect(hts_shim_bcf_gt_allele(phased) == 1)

        let unphased = hts_shim_bcf_gt_unphased(0)
        let isUnphasedResult = hts_shim_bcf_gt_is_phased(unphased) == 0
        #expect(isUnphasedResult)
        #expect(hts_shim_bcf_gt_allele(unphased) == 0)

        let missing = hts_shim_bcf_gt_missing()
        let isMissingResult = hts_shim_bcf_gt_is_missing(missing) != 0
        #expect(isMissingResult)
    }

    @Test func genotypeEquality() {
        let gt1 = Genotype(alleles: [0, 1], phased: [false, false])
        let gt2 = Genotype(alleles: [0, 1], phased: [false, false])
        let gt3 = Genotype(alleles: [1, 1], phased: [false, false])
        #expect(gt1 == gt2)
        #expect(gt1 != gt3)
    }

    @Test func genotypeProperties() {
        let het = Genotype(alleles: [0, 1], phased: [false, false])
        #expect(het.isHeterozygous)
        #expect(!het.isHomozygous)
        #expect(!het.isMissing)
        #expect(het.ploidy == 2)

        let hom = Genotype(alleles: [1, 1], phased: [false, false])
        #expect(!hom.isHeterozygous)
        #expect(hom.isHomozygous)

        let miss = Genotype(alleles: [nil, nil], phased: [false, false])
        #expect(miss.isMissing)
    }
}
