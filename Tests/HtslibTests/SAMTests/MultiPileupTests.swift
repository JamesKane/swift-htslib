// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("MultiPileup")
struct MultiPileupTests {
    @Test func multiPileupSingleFile() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let mplp = MultiPileupIterator(files: [(file: file.pointer, header: header.pointer)])

        var count = 0
        while let column = mplp.next() {
            count += 1
            let nSamples = column.nSamples
            #expect(nSamples == 1)
            let depth = column.depth(forSample: 0)
            #expect(depth == 1)
        }
        #expect(count == 101) // 27M1D73M
    }

    @Test func multiPileupColumnFields() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)
        let mplp = MultiPileupIterator(files: [(file: file.pointer, header: header.pointer)])

        guard let first = mplp.next() else {
            Issue.record("Expected a multi-pileup column")
            return
        }
        #expect(first.contigID == 0)
        #expect(first.position == 1)
        let total = first.totalDepth
        #expect(total == 1)
        #expect(first.sampleEntries.count == 1)
        #expect(first.sampleEntries[0].count == 1)
    }
}
