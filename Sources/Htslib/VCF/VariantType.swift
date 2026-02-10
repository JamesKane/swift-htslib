/// Bitwise flags describing the type(s) of variation at a VCF record.
///
/// A record may have multiple variant types if it contains multiple ALT alleles.
/// Use set operations to test for specific types.
public struct VariantType: OptionSet, Sendable, Hashable {
    public let rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }

    /// Reference (no variation).
    public static let ref: VariantType = []
    /// Single nucleotide polymorphism.
    public static let snp     = VariantType(rawValue: 1 << 0)
    /// Multi-nucleotide polymorphism.
    public static let mnp     = VariantType(rawValue: 1 << 1)
    /// Insertion or deletion.
    public static let indel   = VariantType(rawValue: 1 << 2)
    /// Other variant type not covered by the standard categories.
    public static let other   = VariantType(rawValue: 1 << 3)
    /// Breakend (structural variant).
    public static let bnd     = VariantType(rawValue: 1 << 4)
    /// Overlapping variant.
    public static let overlap = VariantType(rawValue: 1 << 5)
    /// Insertion.
    public static let ins     = VariantType(rawValue: 1 << 6)
    /// Deletion.
    public static let del     = VariantType(rawValue: 1 << 7)
}
