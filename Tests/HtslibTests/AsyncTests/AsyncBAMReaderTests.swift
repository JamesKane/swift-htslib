// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("AsyncBAMReader")
struct AsyncBAMReaderTests {

    @Test func sequentialRead() async throws {
        let reader = try AsyncBAMReader(path: testDataPath("ce#1.sam"))
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 1)
    }

    @Test func multipleRecords() async throws {
        let reader = try AsyncBAMReader(path: testDataPath("auxf#values.sam"))
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 2)
    }

    @Test func headerAccessWithoutAwait() throws {
        let reader = try AsyncBAMReader(path: testDataPath("ce#1.sam"))
        // nonisolated let — no await needed
        let nTargets = reader.header.nTargets
        #expect(nTargets >= 0)
        #expect(reader.path.hasSuffix("ce#1.sam"))
    }

    @Test func exhaustionReturnsNil() async throws {
        let reader = try AsyncBAMReader(path: testDataPath("ce#1.sam"))
        while let _ = try await reader.next() { }
        let hasMore = try await reader.next() != nil
        #expect(!hasMore)
    }

    @Test func setThreads() async throws {
        let reader = try AsyncBAMReader(path: testDataPath("ce#1.sam"))
        let ret = await reader.setThreads(2)
        #expect(ret == 0)
    }

    @Test func initWithThreadPool() async throws {
        let reader = try AsyncBAMReader(
            path: testDataPath("auxf#values.sam"), threads: 2)
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 2)
    }

    @Test func indexedRegionQuery() async throws {
        let reader = try AsyncBAMReader(
            path: testDataPath("range.bam"), loadIndex: true)

        try await reader.query(region: "CHROMOSOME_II")
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 34)
    }

    @Test func indexedQueryByTid() async throws {
        let reader = try AsyncBAMReader(
            path: testDataPath("range.bam"), loadIndex: true)

        // tid 2 = CHROMOSOME_III (0-indexed: I=0, II=1, III=2)
        try await reader.query(tid: 2, start: 0, end: 5000)
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 41)
    }

    @Test func queryResetAndRequery() async throws {
        let reader = try AsyncBAMReader(
            path: testDataPath("range.bam"), loadIndex: true)

        // First query
        try await reader.query(region: "CHROMOSOME_II")
        var count1 = 0
        while let _ = try await reader.next() {
            count1 += 1
        }
        #expect(count1 == 34)

        // Reset and query a different region
        try await reader.query(region: "CHROMOSOME_III")
        var count2 = 0
        while let _ = try await reader.next() {
            count2 += 1
        }
        #expect(count2 == 41)
    }

    @Test func resetQueryToSequential() async throws {
        let reader = try AsyncBAMReader(
            path: testDataPath("range.bam"), loadIndex: true)

        // Start a region query
        try await reader.query(region: "CHROMOSOME_II")
        // Reset to sequential mode (note: file position may be mid-stream)
        await reader.resetQuery()
        // After reset, next() reads sequentially from current file position
        // Just verify it doesn't crash — we may get 0 or some records
        let record = try await reader.next()
        // If we got a record, that's fine; nil is also acceptable
        _ = record
    }

    @Test func queryWithoutIndexThrows() async throws {
        let reader = try AsyncBAMReader(path: testDataPath("ce#1.sam"))
        await #expect(throws: HTSError.self) {
            try await reader.query(region: "chr1")
        }
    }
}
