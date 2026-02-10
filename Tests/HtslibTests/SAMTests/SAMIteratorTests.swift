import Testing
@testable import Htslib

@Suite("SAMIterator")
struct SAMIteratorTests {
    @Test func iterateAllRecords() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        var count = 0
        while var record = iter.next() {
            count += 1
        }
        #expect(count == 1) // ce#1.sam has 1 record
    }

    @Test func iterateMultipleRecords() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        var count = 0
        while var record = iter.next() {
            count += 1
        }
        #expect(count == 2) // auxf#values.sam has 2 records
    }

    @Test func iteratorExhaustion() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        // Consume the one record
        while var record = iter.next() { }
        // Calling again should return nil
        let hasMore = iter.next() != nil
        #expect(!hasMore)
    }

    @Test func recordsHaveCorrectNames() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var first = iter.next() else {
            Issue.record("Expected first record"); return
        }
        #expect(first.queryName == "Fred")

        guard var second = iter.next() else {
            Issue.record("Expected second record"); return
        }
        #expect(second.queryName == "Jim")
    }
}
