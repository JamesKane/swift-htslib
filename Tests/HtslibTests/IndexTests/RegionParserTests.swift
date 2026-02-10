// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("RegionParser")
struct RegionParserTests {
    @Test func parseSimpleRegion() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)

        let (tid, start, end) = try RegionParser.parse(region: "CHROMOSOME_I:100-200", header: header)
        #expect(tid == 0)
        #expect(start == 99)  // 0-based
        #expect(end == 200)
    }

    @Test func parseWholeChromosome() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)

        let (tid, start, end) = try RegionParser.parse(region: "CHROMOSOME_I", header: header)
        #expect(tid == 0)
        #expect(start == 0)
        #expect(end > 0)
    }

    @Test func parseInvalidRegionThrows() throws {
        let file = try HTSFile(path: testDataPath("ce#1.sam"), mode: "r")
        let header = try SAMHeader(from: file)

        #expect(throws: HTSError.self) {
            _ = try RegionParser.parse(region: "NONEXISTENT:100-200", header: header)
        }
    }
}
