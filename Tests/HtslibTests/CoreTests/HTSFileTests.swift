import Testing
import Foundation
@testable import Htslib

@Suite("HTSFile")
struct HTSFileTests {
    @Test func openSAMFileForReading() throws {
        let path = testDataPath("ce#1.sam")
        let file = try HTSFile(path: path, mode: "r")
        #expect(file.path == path)
        #expect(file.mode == "r")
        let isW = file.isWrite
        #expect(!isW)
    }

    @Test func openVCFFileForReading() throws {
        let path = testDataPath("vcf_file.vcf")
        let file = try HTSFile(path: path, mode: "r")
        let isW = file.isWrite
        #expect(!isW)
    }

    @Test func openNonexistentFileThrows() {
        #expect(throws: HTSError.self) {
            _ = try HTSFile(path: "/nonexistent/path.sam", mode: "r")
        }
    }

    @Test func openFileForWriting() throws {
        let path = tempFilePath("write_test.sam")
        defer { try? FileManager.default.removeItem(atPath: path) }
        let file = try HTSFile(path: path, mode: "w")
        let isW = file.isWrite
        #expect(isW)
    }

    @Test func formatDetection() throws {
        let path = testDataPath("ce#1.sam")
        let file = try HTSFile(path: path, mode: "r")
        let fmt = file.format
        let cat = file.category
        #expect(fmt == .sam)
        #expect(cat == .sequenceData)
    }

    @Test func vcfFormatDetection() throws {
        let path = testDataPath("vcf_file.vcf")
        let file = try HTSFile(path: path, mode: "r")
        let fmt = file.format
        let cat = file.category
        #expect(fmt == .vcf)
        #expect(cat == .variantData)
    }
}
