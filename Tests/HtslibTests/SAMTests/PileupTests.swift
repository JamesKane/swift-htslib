// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("Pileup")
struct PileupTests {
    @Test func pileupSingleRecord() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let pileup = PileupIterator(file: file.pointer, header: header.pointer)

        var columnCount = 0
        while let column = pileup.next() {
            columnCount += 1
            #expect(column.depth == 1)
            #expect(column.contigID == 0)
            #expect(column.entries.count == 1)
        }
        // ce#1.sam: 27M1D73M = 101 reference positions covered
        #expect(columnCount == 101)
    }

    @Test func pileupEntryFields() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let pileup = PileupIterator(file: file.pointer, header: header.pointer)

        guard let first = pileup.next() else {
            Issue.record("Expected a pileup column")
            return
        }
        #expect(first.entries.count == 1)
        let entry = first.entries[0]
        #expect(entry.isHead)
        #expect(!entry.isTail)
        #expect(!entry.isDeletion)
        #expect(!entry.isRefSkip)
        #expect(entry.queryPosition == 0)
        #expect(entry.base == "C") // first base of sequence CCTAGCCCTAAC...
    }

    @Test func pileupDeletion() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let pileup = PileupIterator(file: file.pointer, header: header.pointer)

        // CIGAR: 27M1D73M — position 28 (0-based) should be a deletion
        var deletionFound = false
        var colIdx = 0
        while let column = pileup.next() {
            if colIdx == 27 { // 28th column (0-indexed)
                let entry = column.entries[0]
                if entry.isDeletion {
                    deletionFound = true
                    #expect(entry.base == "*")
                }
            }
            colIdx += 1
        }
        #expect(deletionFound)
    }

    @Test func pileupTailEntry() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let pileup = PileupIterator(file: file.pointer, header: header.pointer)

        var lastColumn: PileupColumn? = nil
        while let column = pileup.next() {
            lastColumn = column
        }
        guard let last = lastColumn else {
            Issue.record("Expected pileup columns")
            return
        }
        #expect(last.entries[0].isTail)
    }

    @Test func pileupMaxDepth() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let pileup = PileupIterator(file: file.pointer, header: header.pointer)
        pileup.setMaxDepth(100)

        // Should still work normally with 1 record
        var count = 0
        while let _ = pileup.next() {
            count += 1
        }
        #expect(count == 101)
    }

    @Test func pileupPositions() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let pileup = PileupIterator(file: file.pointer, header: header.pointer)

        guard let first = pileup.next() else {
            Issue.record("Expected a pileup column")
            return
        }
        // ce#1.sam record starts at position 1 (0-based)
        #expect(first.position == 1)
    }
}
