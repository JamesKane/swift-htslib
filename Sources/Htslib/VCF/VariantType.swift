public struct VariantType: OptionSet, Sendable, Hashable {
    public let rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue }

    public static let ref: VariantType = []
    public static let snp     = VariantType(rawValue: 1 << 0)
    public static let mnp     = VariantType(rawValue: 1 << 1)
    public static let indel   = VariantType(rawValue: 1 << 2)
    public static let other   = VariantType(rawValue: 1 << 3)
    public static let bnd     = VariantType(rawValue: 1 << 4)
    public static let overlap = VariantType(rawValue: 1 << 5)
    public static let ins     = VariantType(rawValue: 1 << 6)
    public static let del     = VariantType(rawValue: 1 << 7)
}
