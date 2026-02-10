import Testing
@testable import Htslib

@Suite("BaseModification")
struct BaseModificationTests {
    @Test func allocateState() throws {
        // Basic allocation/deallocation test
        let state = try BaseModificationState()
        _ = state // ensure it's used
    }

    @Test func parseRecordWithoutMods() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        let state = try BaseModificationState()
        // Record without MM/ML tags — parse should succeed (no mods)
        try state.parse(record: record)

        // No recorded modifications
        let types = state.recordedModifications()
        #expect(types.isEmpty)
    }

    @Test func iterateNoMods() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        let state = try BaseModificationState()
        try state.parse(record: record)

        // nextModification should return nil immediately (no mods)
        let result = state.nextModification(record: record)
        let isNil = result == nil
        #expect(isNil)
    }

    @Test func baseModificationProperties() {
        // Test the BaseModification struct directly
        let mod = BaseModification(
            modifiedBase: Int32(Character("m").asciiValue!),
            canonicalBase: Int32(Character("C").asciiValue!),
            strand: 0,
            quality: 230
        )
        #expect(mod.canonicalBaseCharacter == "C")
        #expect(mod.hasQuality)
        let prob = mod.probability!
        #expect(prob > 0.89 && prob < 0.91) // 230/256 ≈ 0.898

        let unknownMod = BaseModification(
            modifiedBase: Int32(Character("h").asciiValue!),
            canonicalBase: Int32(Character("C").asciiValue!),
            strand: 0,
            quality: -1
        )
        #expect(!unknownMod.hasQuality)
        let isNil = unknownMod.probability == nil
        #expect(isNil)
    }

    @Test func modificationsAtPosition() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let iter = SAMRecordIterator(file: file.pointer, header: header.pointer)

        guard var record = iter.next() else {
            Issue.record("Expected a record")
            return
        }

        let state = try BaseModificationState()
        try state.parse(record: record)

        // No mods, so should return empty arrays
        let mods = state.modificationsAtPosition(record: record, queryPosition: 0)
        #expect(mods != nil)
        #expect(mods!.isEmpty)
    }
}
