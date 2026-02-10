import Testing
@testable import Htslib

@Suite("VCFIterator")
struct VCFIteratorTests {
    @Test func countAllRecords() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        var count = 0
        while var record = iter.next() {
            count += 1
        }
        #expect(count == 15)
    }

    @Test func iteratorExhaustion() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        while var record = iter.next() { }
        let hasMore = iter.next() != nil
        #expect(!hasMore)
    }

    @Test func recordsOnMultipleContigs() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        var contigs = Set<Int32>()
        while let record = iter.next() {
            contigs.insert(record.contigID)
        }
        #expect(contigs.count == 4)
    }

    @Test func consecutiveRecordsHaveNonDecreasingPositions() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        var prevContig: Int32 = -1
        var prevPos: Int64 = -1
        while let record = iter.next() {
            if record.contigID == prevContig {
                #expect(record.position >= prevPos)
            }
            prevContig = record.contigID
            prevPos = record.position
        }
    }
}
