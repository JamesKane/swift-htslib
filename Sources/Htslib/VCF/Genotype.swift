import CHtslib
import CHTSlibShims

public struct Genotype: Sendable, Hashable {
    public let alleles: [Int?]
    public let phased: [Bool]

    public var ploidy: Int { alleles.count }

    public var isMissing: Bool {
        alleles.allSatisfy { $0 == nil }
    }

    public var isHeterozygous: Bool {
        let nonMissing = alleles.compactMap { $0 }
        guard nonMissing.count >= 2 else { return false }
        return Set(nonMissing).count > 1
    }

    public var isHomozygous: Bool {
        let nonMissing = alleles.compactMap { $0 }
        guard nonMissing.count >= 2 else { return false }
        return Set(nonMissing).count == 1
    }

    /// Decode genotypes from BCF-encoded GT array for a single sample
    public static func decode(from gtArray: UnsafePointer<Int32>, ploidy: Int) -> Genotype {
        var alleles = [Int?]()
        var phased = [Bool]()

        for i in 0..<ploidy {
            let val = gtArray[i]
            if val == hts_shim_bcf_int32_vector_end() {
                break
            }
            if hts_shim_bcf_gt_is_missing(val) != 0 {
                alleles.append(nil)
            } else {
                alleles.append(Int(hts_shim_bcf_gt_allele(val)))
            }
            phased.append(i > 0 && hts_shim_bcf_gt_is_phased(val) != 0)
        }

        return Genotype(alleles: alleles, phased: phased)
    }
}
