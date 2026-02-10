import Testing
@testable import Htslib

@Suite("AuxiliaryData")
struct AuxiliaryDataTests {
    @Test func containsTag() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let aux = record.auxiliaryData
        let hasRG = aux.contains("RG")
        let hasI0 = aux.contains("I0")
        let hasZZ = aux.contains("ZZ")
        #expect(hasRG)
        #expect(hasI0)
        #expect(!hasZZ)
    }

    @Test func stringTag() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let rg = record.auxiliaryData.string(forTag: "RG")
        #expect(rg == "ID")
    }

    @Test func integerTags() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let aux = record.auxiliaryData
        #expect(aux.integer(forTag: "I0") == 0)
        #expect(aux.integer(forTag: "I1") == 1)
        #expect(aux.integer(forTag: "I2") == 127)
        #expect(aux.integer(forTag: "I3") == 128)
        #expect(aux.integer(forTag: "I4") == 255)
        #expect(aux.integer(forTag: "I5") == 256)
        #expect(aux.integer(forTag: "IA") == 2147483647)
    }

    @Test func negativeIntegerTags() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let aux = record.auxiliaryData
        #expect(aux.integer(forTag: "i1") == -1)
        #expect(aux.integer(forTag: "i2") == -127)
        #expect(aux.integer(forTag: "i3") == -128)
        #expect(aux.integer(forTag: "iB") == -2147483648)
    }

    @Test func floatTags() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let aux = record.auxiliaryData
        let f0 = aux.float(forTag: "F0")
        #expect(f0 != nil)
        #expect(f0! == -1.0)
        let f1 = aux.float(forTag: "F1")
        #expect(f1 != nil)
        #expect(f1! == 0.0)
        let f2 = aux.float(forTag: "F2")
        #expect(f2 != nil)
        #expect(f2! == 1.0)
    }

    @Test func characterTag() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let aux = record.auxiliaryData
        #expect(aux.character(forTag: "Ac") == "c")
        #expect(aux.character(forTag: "AC") == "C")
    }

    @Test func spaceInStringTag() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        #expect(record.auxiliaryData.string(forTag: "Z0") == "space space")
    }

    @Test func missingTagReturnsNil() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        guard var record = iter.next() else {
            Issue.record("Expected a record"); return
        }

        let aux = record.auxiliaryData
        #expect(aux.string(forTag: "ZZ") == nil)
        #expect(aux.integer(forTag: "ZZ") == nil)
        #expect(aux.float(forTag: "ZZ") == nil)
    }

    @Test func arrayTags() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)
        _ = iter.next() // skip first record
        guard var record = iter.next() else {
            Issue.record("Expected second record"); return
        }

        let aux = record.auxiliaryData
        // BC:B:C,0,127,128,255
        let len = aux.arrayLength(forTag: "BC")
        #expect(len == 4)
        #expect(aux.arrayInteger(forTag: "BC", index: 0) == 0)
        #expect(aux.arrayInteger(forTag: "BC", index: 1) == 127)
        #expect(aux.arrayInteger(forTag: "BC", index: 2) == 128)
        #expect(aux.arrayInteger(forTag: "BC", index: 3) == 255)
    }
}
