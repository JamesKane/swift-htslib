import Testing
@testable import Htslib

@Suite("FASTAIndex")
struct FASTAIndexTests {
    @Test func loadIndex() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let count = fai.sequenceCount
        #expect(count == 1)
    }

    @Test func sequenceName() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let name = fai.sequenceName(at: 0)
        #expect(name == "c1")
    }

    @Test func sequenceLength() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let len = fai.sequenceLength(name: "c1")
        #expect(len == 10) // c1.fa: AACCGCGGTT = 10 bases
    }

    @Test func hasSequence() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let has = fai.hasSequence(name: "c1")
        let hasNot = fai.hasSequence(name: "nonexistent")
        #expect(has)
        #expect(!hasNot)
    }

    @Test func fetchRegion() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        let seq = try fai.fetch(region: "c1:1-10")
        #expect(seq == "AACCGCGGTT")
    }

    @Test func fetchSubsequence() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        // faidx_fetch_seq64 uses 0-based coords
        let seq = try fai.fetch(sequence: "c1", start: 0, end: 3)
        #expect(seq == "AACC")
    }

    @Test func multiSequenceFASTA() throws {
        let fai = try FASTAIndex(path: testDataPath("ce.fa"))
        let count = fai.sequenceCount
        #expect(count == 7)
        let name = fai.sequenceName(at: 0)
        #expect(name == "CHROMOSOME_I")
        let len = fai.sequenceLength(name: "CHROMOSOME_I")
        #expect(len == 1009800)
    }

    @Test func fetchFromMultiSequence() throws {
        let fai = try FASTAIndex(path: testDataPath("ce.fa"))
        // First bases of CHROMOSOME_I
        let seq = try fai.fetch(sequence: "CHROMOSOME_I", start: 0, end: 9)
        #expect(seq == "GCCTAAGCCT")
    }

    @Test func nonexistentFileThrows() {
        #expect(throws: HTSError.self) {
            _ = try FASTAIndex(path: "/nonexistent/path.fa")
        }
    }

    @Test func nonexistentRegionThrows() throws {
        let fai = try FASTAIndex(path: testDataPath("c1.fa"))
        do {
            _ = try fai.fetch(region: "nonexistent:1-10")
            Issue.record("Expected an error for nonexistent region")
        } catch {
            let isHTSError = error is HTSError
            #expect(isHTSError)
        }
    }
}
