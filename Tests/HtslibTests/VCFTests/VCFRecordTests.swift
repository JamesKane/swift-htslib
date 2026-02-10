import Testing
import CHtslib
@testable import Htslib

@Suite("VCFRecord")
struct VCFRecordTests {
    @Test func readFirstRecord() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        let pos = record.position
        #expect(pos >= 0)
    }

    @Test func recordPosition() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        // First record: 1  3000150 (0-based = 3000149)
        #expect(record.position == 3000149)
        #expect(record.contigID == 0)
    }

    @Test func recordQuality() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        let qual = record.quality
        #expect(qual > 59.0)
        #expect(qual < 60.0)
    }

    @Test func recordAlleles() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        try record.unpack(.str)
        let alleles = record.alleles
        #expect(alleles.count == 2)
        #expect(alleles[0] == "C")
        #expect(alleles[1] == "T")
    }

    @Test func recordNAlleles() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        #expect(record.nAlleles == 2)
    }

    @Test func recordID() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        // Skip to record with ID (3rd record: id3D)
        _ = iter.next()
        _ = iter.next()
        guard var record = iter.next() else {
            Issue.record("Expected third record"); return
        }
        try record.unpack(.str)
        #expect(record.id == "id3D")
    }

    @Test func infoInt32() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        try record.unpack(.info)
        let an = record.infoInt32(forKey: "AN", header: header)
        #expect(an != nil)
        #expect(an!.count == 1)
        #expect(an![0] == 4)

        let ac = record.infoInt32(forKey: "AC", header: header)
        #expect(ac != nil)
        #expect(ac!.count == 1)
        #expect(ac![0] == 2)
    }

    @Test func infoFlag() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        _ = iter.next()
        _ = iter.next()
        guard var record = iter.next() else {
            Issue.record("Expected third record"); return
        }
        try record.unpack(.info)
        let hasIndel = record.infoFlag(forKey: "INDEL", header: header)
        let hasNonExist = record.infoFlag(forKey: "NONEXIST", header: header)
        #expect(hasIndel)
        #expect(!hasNonExist)
    }

    @Test func infoString() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        _ = iter.next()
        _ = iter.next()
        guard var record = iter.next() else {
            Issue.record("Expected third record"); return
        }
        try record.unpack(.info)
        let str = record.infoString(forKey: "STR", header: header)
        #expect(str == "test")
    }

    @Test func variantType() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        let vtype = record.variantType
        let isSNP = vtype.contains(.snp)
        #expect(isSNP)
    }

    @Test func unpackLevels() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let iter = VCFRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }
        try record.unpack(.str)
        try record.unpack(.flt)
        try record.unpack(.info)
        try record.unpack(.all)
    }
}
