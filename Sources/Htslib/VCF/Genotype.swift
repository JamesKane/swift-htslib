// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// A decoded genotype for a single sample at a VCF record.
///
/// Each genotype contains an array of allele indices and phasing information.
/// Allele indices are 0-based (0 = REF, 1 = first ALT, etc.), with `nil`
/// representing a missing allele (`.` in VCF notation).
public struct Genotype: Sendable, Hashable {
    /// The allele indices for each haplotype. `nil` represents a missing allele.
    public let alleles: [Int?]
    /// Whether each allele boundary is phased (`|`) rather than unphased (`/`).
    /// The first element is always `false` (phasing applies between alleles).
    public let phased: [Bool]

    /// The ploidy of this genotype (number of alleles).
    public var ploidy: Int { alleles.count }

    /// Whether all alleles are missing.
    public var isMissing: Bool {
        alleles.allSatisfy { $0 == nil }
    }

    /// Whether the genotype is heterozygous (at least two distinct non-missing alleles).
    public var isHeterozygous: Bool {
        let nonMissing = alleles.compactMap { $0 }
        guard nonMissing.count >= 2 else { return false }
        return Set(nonMissing).count > 1
    }

    /// Whether the genotype is homozygous (all non-missing alleles are identical).
    public var isHomozygous: Bool {
        let nonMissing = alleles.compactMap { $0 }
        guard nonMissing.count >= 2 else { return false }
        return Set(nonMissing).count == 1
    }

    /// Decode a genotype from a BCF-encoded GT array for a single sample.
    ///
    /// - Parameters:
    ///   - gtArray: Pointer to the BCF-encoded genotype integers.
    ///   - ploidy: Maximum ploidy (number of elements to read).
    /// - Returns: A decoded ``Genotype``.
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
