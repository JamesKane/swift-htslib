import Testing
@testable import Htslib

@Suite("VCFHeader")
struct VCFHeaderTests {
    @Test func readHeaderFromFile() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        #expect(header.nSamples == 2)
    }

    @Test func sampleNames() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let samples = header.samples
        #expect(samples.count == 2)
        #expect(samples[0] == "A")
        #expect(samples[1] == "B")
    }

    @Test func copyHeader() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        let copy = header.copy()
        #expect(copy != nil)
        #expect(copy!.nSamples == 2)
        #expect(copy!.samples == ["A", "B"])
    }

    @Test func createEmptyHeader() throws {
        let header = try VCFHeader(mode: "w")
        #expect(header.nSamples == 0)
    }

    @Test func addSample() throws {
        let header = try VCFHeader(mode: "w")
        _ = header.addSample("Sample1")
        _ = header.addSample("Sample2")
        _ = header.sync()
        #expect(header.nSamples == 2)
    }

    @Test func appendHeaderLine() throws {
        let header = try VCFHeader(mode: "w")
        let ret = header.append(line: "##INFO=<ID=DP,Number=1,Type=Integer,Description=\"Read Depth\">")
        #expect(ret == 0)
    }

    @Test func headerIDLookup() throws {
        let file = try HTSFile(path: testDataPath("vcf_file.vcf"), mode: "r")
        let header = try VCFHeader(from: file)
        // BCF_DT_ID = 0 for ID fields
        let id = header.headerID(for: 0, name: "PASS")
        #expect(id >= 0)
    }
}
