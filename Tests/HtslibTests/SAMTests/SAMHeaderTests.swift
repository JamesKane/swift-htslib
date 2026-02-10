import Testing
import Foundation
@testable import Htslib

@Suite("SAMHeader")
struct SAMHeaderTests {
    @Test func readHeaderFromFile() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        #expect(header.nTargets == 1)
    }

    @Test func targetNameLookup() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let name = header.targetName(at: 0)
        #expect(name == "CHROMOSOME_I")
    }

    @Test func targetLengthLookup() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let len = header.targetLength(at: 0)
        #expect(len == 1009800)
    }

    @Test func targetIDByName() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let tid = header.targetID(forName: "CHROMOSOME_I")
        #expect(tid == 0)
    }

    @Test func unknownTargetReturnsNegative() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let tid = header.targetID(forName: "nonexistent")
        #expect(tid < 0)
    }

    @Test func headerText() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let text = header.text
        #expect(text != nil)
        #expect(text!.contains("CHROMOSOME_I"))
    }

    @Test func headerLength() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        #expect(header.length > 0)
    }

    @Test func copyHeader() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let copy = header.copy()
        #expect(copy != nil)
        #expect(copy!.nTargets == header.nTargets)
        #expect(copy!.targetName(at: 0) == "CHROMOSOME_I")
    }

    @Test func createEmptyHeader() throws {
        let header = try SAMHeader()
        #expect(header.nTargets == 0)
    }

    @Test func multiTargetHeader() throws {
        let file = try HTSFile(path: testDataPath("auxf#values.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        #expect(header.nTargets == 1)
        #expect(header.targetName(at: 0) == "Sheila")
        #expect(header.targetLength(at: 0) == 20)
    }
}
