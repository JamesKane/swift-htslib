// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("AlignmentFlag")
struct AlignmentFlagTests {
    @Test func pairedFlag() {
        let flag = AlignmentFlag(rawValue: 0x1)
        #expect(flag.contains(.paired))
        #expect(!flag.contains(.unmapped))
    }

    @Test func unmappedFlag() {
        let flag = AlignmentFlag(rawValue: 0x4)
        #expect(flag.contains(.unmapped))
        #expect(!flag.contains(.paired))
    }

    @Test func reverseFlag() {
        let flag = AlignmentFlag(rawValue: 0x10)
        #expect(flag.contains(.reverse))
    }

    @Test func combinedFlags() {
        let flag: AlignmentFlag = [.paired, .properPair, .reverse]
        #expect(flag.contains(.paired))
        #expect(flag.contains(.properPair))
        #expect(flag.contains(.reverse))
        #expect(!flag.contains(.unmapped))
    }

    @Test func secondaryFlag() {
        let flag = AlignmentFlag(rawValue: 0x100)
        #expect(flag.contains(.secondary))
    }

    @Test func supplementaryFlag() {
        let flag = AlignmentFlag(rawValue: 0x800)
        #expect(flag.contains(.supplementary))
    }

    @Test func duplicateFlag() {
        let flag = AlignmentFlag(rawValue: 0x400)
        #expect(flag.contains(.duplicate))
    }

    @Test func emptyFlag() {
        let flag = AlignmentFlag(rawValue: 0)
        #expect(!flag.contains(.paired))
        #expect(!flag.contains(.unmapped))
        #expect(!flag.contains(.reverse))
    }
}
