// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
@testable import Htslib

@Suite("SyncedBCFReader")
struct SyncedBCFReaderTests {
    @Test func createReader() throws {
        let reader = try SyncedBCFReader()
        let n = reader.nReaders
        #expect(n == 0)
    }

    @Test func readSingleVCF() throws {
        let reader = try SyncedBCFReader()
        reader.allowNoIndex()
        try reader.addReader(path: testDataPath("vcf_file.vcf"))

        let n = reader.nReaders
        #expect(n == 1)

        var count = 0
        while reader.nextLine() > 0 {
            if reader.hasLine(at: 0) {
                count += 1
            }
        }
        #expect(count == 15)
    }

    @Test func getHeader() throws {
        let reader = try SyncedBCFReader()
        reader.allowNoIndex()
        try reader.addReader(path: testDataPath("vcf_file.vcf"))

        let header = reader.getHeader(at: 0)
        #expect(header != nil)
        let nSamples = header!.nSamples
        #expect(nSamples == 2)
    }

    @Test func getRecord() throws {
        let reader = try SyncedBCFReader()
        reader.allowNoIndex()
        try reader.addReader(path: testDataPath("vcf_file.vcf"))

        let ret = reader.nextLine()
        #expect(ret > 0)
        #expect(reader.hasLine(at: 0))

        guard var record = reader.getRecord(at: 0) else {
            Issue.record("Expected a record")
            return
        }
        // First record position should match vcf_file.vcf
        let pos = record.position
        #expect(pos == 3000149) // 0-based
    }

    @Test func nonexistentFileThrows() throws {
        let reader = try SyncedBCFReader()
        reader.allowNoIndex()
        do {
            try reader.addReader(path: "/nonexistent/file.vcf")
            Issue.record("Expected an error")
        } catch {
            let isHTSError = error is HTSError
            #expect(isHTSError)
        }
    }

    @Test func recordAlleles() throws {
        let reader = try SyncedBCFReader()
        reader.allowNoIndex()
        try reader.addReader(path: testDataPath("vcf_file.vcf"))

        let ret = reader.nextLine()
        #expect(ret > 0)

        guard var record = reader.getRecord(at: 0) else {
            Issue.record("Expected a record")
            return
        }
        try record.unpack(.str)
        let alleles = record.alleles
        #expect(alleles.count == 2)
        #expect(alleles[0] == "C")
        #expect(alleles[1] == "T")
    }
}
