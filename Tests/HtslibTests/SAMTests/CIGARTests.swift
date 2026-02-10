// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("CIGAROperation")
struct CIGARTests {
    @Test func matchOperation() {
        // CIGAR encoded as (length << 4 | op), M=0
        let raw: UInt32 = (10 << 4) | 0 // 10M
        let op = CIGAROperation(rawValue: raw)
        #expect(op.op == .match)
        #expect(op.length == 10)
        #expect(op.character == "M")
        #expect(op.consumesQuery)
        #expect(op.consumesReference)
    }

    @Test func insertionOperation() {
        let raw: UInt32 = (5 << 4) | 1 // 5I
        let op = CIGAROperation(rawValue: raw)
        #expect(op.op == .insertion)
        #expect(op.length == 5)
        #expect(op.character == "I")
        #expect(op.consumesQuery)
        #expect(!op.consumesReference)
    }

    @Test func deletionOperation() {
        let raw: UInt32 = (3 << 4) | 2 // 3D
        let op = CIGAROperation(rawValue: raw)
        #expect(op.op == .deletion)
        #expect(op.length == 3)
        #expect(op.character == "D")
        #expect(!op.consumesQuery)
        #expect(op.consumesReference)
    }

    @Test func softClipOperation() {
        let raw: UInt32 = (20 << 4) | 4 // 20S
        let op = CIGAROperation(rawValue: raw)
        #expect(op.op == .softClip)
        #expect(op.length == 20)
        #expect(op.character == "S")
        #expect(op.consumesQuery)
        #expect(!op.consumesReference)
    }

    @Test func hardClipOperation() {
        let raw: UInt32 = (15 << 4) | 5 // 15H
        let op = CIGAROperation(rawValue: raw)
        #expect(op.op == .hardClip)
        #expect(op.length == 15)
        #expect(op.character == "H")
        #expect(!op.consumesQuery)
        #expect(!op.consumesReference)
    }

    @Test func skipOperation() {
        let raw: UInt32 = (1000 << 4) | 3 // 1000N
        let op = CIGAROperation(rawValue: raw)
        #expect(op.op == .refSkip)
        #expect(op.length == 1000)
        #expect(op.character == "N")
    }
}
