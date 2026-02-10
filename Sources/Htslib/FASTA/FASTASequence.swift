import CHtslib

/// Metadata about a named sequence in a FASTA file.
public struct FASTASequence: Sendable, Hashable {
    /// Sequence name (e.g., "chr1", "CHROMOSOME_I")
    public let name: String
    /// Length in bases
    public let length: Int64
    /// 0-based index in the FASTA file
    public let index: Int
}

extension FASTAIndex {
    /// List all sequences in the FASTA index.
    public var sequences: [FASTASequence] {
        let n = sequenceCount
        var result: [FASTASequence] = []
        result.reserveCapacity(n)
        for i in 0..<n {
            guard let name = sequenceName(at: i) else { continue }
            let len = sequenceLength(name: name)
            result.append(FASTASequence(name: name, length: len, index: i))
        }
        return result
    }

    /// Fetch the full sequence for a FASTASequence entry.
    public func fetch(sequence: FASTASequence) throws -> String {
        try fetch(sequence: sequence.name, start: 0, end: sequence.length - 1)
    }
}
