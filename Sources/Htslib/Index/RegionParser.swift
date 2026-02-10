import CHtslib

/// Parse a region string like "chr1:1000-2000" into components
public struct RegionParser: Sendable {
    public static func parse(region: String, header: SAMHeader) throws -> (tid: Int32, start: Int64, end: Int64) {
        var tid: Int32 = 0
        var beg: Int64 = 0
        var end: Int64 = 0

        let result = region.withCString { regionPtr in
            sam_parse_region(header.pointer, regionPtr, &tid, &beg, &end, 0)
        }

        guard result != nil else {
            throw HTSError.regionParseFailed(region: region)
        }

        return (tid: tid, start: beg, end: end)
    }
}
