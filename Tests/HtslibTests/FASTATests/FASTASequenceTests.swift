import Testing
@testable import Htslib

@Suite("FASTASequence")
struct FASTASequenceTests {
    @Test func listSequences() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let seqs = fai.sequences
        #expect(seqs.count == 1)
        #expect(seqs[0].name == "c1")
        #expect(seqs[0].length == 10)
        #expect(seqs[0].index == 0)
    }

    @Test func multipleSequences() throws {
        let fai = try FASTAIndex(path: testDataPath("ce.fa"))
        let seqs = fai.sequences
        #expect(seqs.count == 7)
        #expect(seqs[0].name == "CHROMOSOME_I")
        #expect(seqs[0].length == 1009800)
    }

    @Test func fetchFullSequence() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let seqs = fai.sequences
        let seq = try fai.fetch(sequence: seqs[0])
        #expect(seq == "AACCGCGGTT")
    }

    @Test func sequenceEquality() {
        let a = FASTASequence(name: "chr1", length: 1000, index: 0)
        let b = FASTASequence(name: "chr1", length: 1000, index: 0)
        let c = FASTASequence(name: "chr2", length: 2000, index: 1)
        #expect(a == b)
        #expect(a != c)
    }

    @Test func sequenceHashable() {
        let a = FASTASequence(name: "chr1", length: 1000, index: 0)
        let b = FASTASequence(name: "chr2", length: 2000, index: 1)
        let set: Set<FASTASequence> = [a, b]
        #expect(set.count == 2)
    }
}
