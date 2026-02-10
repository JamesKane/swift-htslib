// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("AsyncVCFReader")
struct AsyncVCFReaderTests {

    @Test func sequentialRead() async throws {
        let reader = try AsyncVCFReader(path: testDataPath("vcf_file.vcf"))
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 15)
    }

    @Test func headerAccessWithoutAwait() throws {
        let reader = try AsyncVCFReader(path: testDataPath("vcf_file.vcf"))
        // nonisolated let — no await needed
        let nSamples = reader.header.nSamples
        #expect(nSamples >= 0)
        #expect(reader.path.hasSuffix("vcf_file.vcf"))
    }

    @Test func recordFields() async throws {
        let reader = try AsyncVCFReader(path: testDataPath("vcf_file.vcf"))
        guard let record = try await reader.next() else {
            Issue.record("Expected at least one record")
            return
        }
        // First record should have a valid position (0-based)
        #expect(record.position >= 0)
    }

    @Test func exhaustionReturnsNil() async throws {
        let reader = try AsyncVCFReader(path: testDataPath("vcf_file.vcf"))
        while let _ = try await reader.next() { }
        let hasMore = try await reader.next() != nil
        #expect(!hasMore)
    }

    @Test func initWithThreadPool() async throws {
        let reader = try AsyncVCFReader(
            path: testDataPath("vcf_file.vcf"), threads: 2)
        var count = 0
        while let _ = try await reader.next() {
            count += 1
        }
        #expect(count == 15)
    }
}
