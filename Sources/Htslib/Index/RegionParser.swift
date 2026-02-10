// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// Parses samtools-style region strings into numeric components.
public struct RegionParser: Sendable {
    /// Parse a region string into a target ID, start, and end position.
    ///
    /// Accepts formats like `"chr1"`, `"chr1:1000"`, `"chr1:1000-2000"`.
    ///
    /// - Parameters:
    ///   - region: The region string to parse.
    ///   - header: The ``SAMHeader`` used to resolve contig names to IDs.
    /// - Returns: A tuple of `(tid, start, end)` where `tid` is the 0-based reference
    ///   sequence ID, `start` is the 0-based inclusive start, and `end` is the 0-based
    ///   exclusive end.
    /// - Throws: ``HTSError/regionParseFailed(region:)`` if the region cannot be parsed.
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
