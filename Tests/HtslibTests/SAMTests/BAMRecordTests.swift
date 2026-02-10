import Testing
import Foundation
@testable import Htslib
import CHtslib

@Suite("BAMRecord")
struct BAMRecordTests {
    @Test func readFirstRecord() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }
        let name = record.queryName
        #expect(!name.isEmpty)
    }

    @Test func recordFields() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        #expect(record.queryName == "SRR065390.14978392")
        #expect(record.contigID == 0)
        #expect(record.position == 1) // 0-based
        #expect(record.mappingQuality == 1)
        let isRev = record.isReverse
        let isUnm = record.isUnmapped
        let isSec = record.isSecondary
        let isSup = record.isSupplementary
        #expect(isRev)
        #expect(!isUnm)
        #expect(!isSec)
        #expect(!isSup)
    }

    @Test func cigarAccess() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        // ce#1.sam has CIGAR: 27M1D73M
        let cigar = record.cigar
        #expect(cigar.count == 3)
        #expect(cigar[0].op == .match)
        #expect(cigar[0].length == 27)
        #expect(cigar[1].op == .deletion)
        #expect(cigar[1].length == 1)
        #expect(cigar[2].op == .match)
        #expect(cigar[2].length == 73)
    }

    @Test func sequenceAccess() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        let seq = record.sequence
        #expect(seq.count == 100)
        let seqStr = seq.string
        #expect(seqStr.hasPrefix("CCTAGCCCTAACCCTAACCCTAACCC"))
    }

    @Test func qualityAccess() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        let quals = record.qualities
        #expect(quals.count == 100)
        for i in 0..<quals.count {
            #expect(quals[i] <= 93)
        }
    }

    @Test func endPosition() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        // 27M1D73M = 27 + 1 + 73 = 101 ref bases, pos = 1
        #expect(record.endPosition == 102)
    }

    @Test func flagAccess() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        let flag = record.flag
        #expect(flag.contains(.reverse))
        #expect(!flag.contains(.paired))
    }

    @Test func writeAndReadBack() throws {
        let path = tempFilePath("roundtrip.sam")
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Read
        let inFile = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: inFile)
        let iter = SAMRecordIterator(file: inFile.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }
        let origName = record.queryName
        let origPos = record.position

        // Write
        do {
            let outFile = try HTSFile(path: path, mode: "w")
            try header.write(to: outFile)
            let ret = sam_write1(outFile.pointer, header.pointer, record.pointer)
            #expect(ret >= 0)
        } // outFile deinit closes it

        // Read back
        let inFile2 = try HTSFile(path: path, mode: "r")
        let header2 = try SAMHeader(from: inFile2)
        let iter2 = SAMRecordIterator(file: inFile2.pointer, header: header2.pointer)
        guard var record2 = iter2.next() else {
            Issue.record("Expected a record on readback")
            return
        }
        #expect(record2.queryName == origName)
        #expect(record2.position == origPos)
    }
}
