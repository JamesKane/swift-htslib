// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Testing
import Foundation
@testable import Htslib

@Suite("BGZFFile")
struct BGZFTests {
    @Test func openBGZFForReading() throws {
        let bgzf = try BGZFFile(path: testDataPath("bgziptest.txt.gz"), mode: "r")
        let isC = bgzf.isCompressed
        #expect(isC)
    }

    @Test func readBGZFContent() throws {
        var bgzf = try BGZFFile(path: testDataPath("bgziptest.txt.gz"), mode: "r")
        var buffer = [UInt8](repeating: 0, count: 256)
        let bytesRead = try buffer.withUnsafeMutableBufferPointer {
            try bgzf.read(into: $0.baseAddress!, length: 256)
        }
        #expect(bytesRead == 15) // "122333444455555" = 15 bytes
        let content = String(bytes: buffer.prefix(bytesRead), encoding: .utf8)
        #expect(content == "122333444455555")
    }

    @Test func virtualOffset() throws {
        let bgzf = try BGZFFile(path: testDataPath("bgziptest.txt.gz"), mode: "r")
        let offset = bgzf.virtualOffset
        #expect(offset == 0) // at the start
    }

    @Test func writeAndReadRoundtrip() throws {
        let path = tempFilePath("bgzf_roundtrip.gz")
        defer { try? FileManager.default.removeItem(atPath: path) }

        let testString = "Hello, BGZF!"
        let data = Array(testString.utf8)

        // Write
        do {
            var writer = try BGZFFile(path: path, mode: "w")
            let written = try data.withUnsafeBufferPointer {
                try writer.write(from: $0.baseAddress!, length: $0.count)
            }
            #expect(written == data.count)
            try writer.flush()
        } // writer deinit closes it

        // Read back
        do {
            var reader = try BGZFFile(path: path, mode: "r")
            var buffer = [UInt8](repeating: 0, count: 256)
            let bytesRead = try buffer.withUnsafeMutableBufferPointer {
                try reader.read(into: $0.baseAddress!, length: 256)
            }
            let result = String(bytes: buffer.prefix(bytesRead), encoding: .utf8)
            #expect(result == testString)
        }
    }

    @Test func nonexistentFileThrows() {
        #expect(throws: HTSError.self) {
            _ = try BGZFFile(path: "/nonexistent/file.gz", mode: "r")
        }
    }
}
