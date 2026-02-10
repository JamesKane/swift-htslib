// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

/// Iterates all records sequentially from a SAM/BAM/CRAM file.
///
/// Since ``BAMRecord`` is `~Copyable`, this class cannot conform to `IteratorProtocol`.
/// Use a `while let` loop instead:
/// ```swift
/// while let record = iterator.next() {
///     print(record.queryName)
/// }
/// ```
public final class SAMRecordIterator {
    private let file: UnsafeMutablePointer<htsFile>
    private let header: UnsafeMutablePointer<sam_hdr_t>
    private var record: UnsafeMutablePointer<bam1_t>?
    private var exhausted = false

    internal init(file: UnsafeMutablePointer<htsFile>, header: UnsafeMutablePointer<sam_hdr_t>) {
        self.file = file
        self.header = header
        self.record = bam_init1()
    }

    /// Read the next alignment record.
    ///
    /// - Returns: The next ``BAMRecord``, or `nil` at end-of-file.
    public func next() -> BAMRecord? {
        guard !exhausted, let rec = record else { return nil }
        let ret = sam_read1(file, header, rec)
        if ret >= 0 {
            let result = rec
            self.record = bam_init1()
            return BAMRecord(pointer: result)
        } else {
            exhausted = true
            return nil
        }
    }

    deinit {
        if let rec = record {
            bam_destroy1(rec)
        }
    }
}

/// Iterates records overlapping a genomic region using an index.
///
/// Since ``BAMRecord`` is `~Copyable`, this class cannot conform to `IteratorProtocol`.
/// Use a `while let` loop instead:
/// ```swift
/// while let record = iterator.next() {
///     print(record.queryName)
/// }
/// ```
public final class SAMQueryIterator {
    private let file: UnsafeMutablePointer<htsFile>
    private let iterator: UnsafeMutablePointer<hts_itr_t>
    private var record: UnsafeMutablePointer<bam1_t>?
    private var exhausted = false

    internal init(file: UnsafeMutablePointer<htsFile>,
                  iterator: UnsafeMutablePointer<hts_itr_t>) {
        self.file = file
        self.iterator = iterator
        self.record = bam_init1()
    }

    /// Read the next alignment record in the queried region.
    ///
    /// - Returns: The next ``BAMRecord`` overlapping the region, or `nil` when exhausted.
    public func next() -> BAMRecord? {
        guard !exhausted, let rec = record else { return nil }
        let ret = hts_shim_sam_itr_next(file, iterator, rec)
        if ret >= 0 {
            let result = rec
            self.record = bam_init1()
            return BAMRecord(pointer: result)
        } else {
            exhausted = true
            return nil
        }
    }

    deinit {
        hts_itr_destroy(iterator)
        if let rec = record {
            bam_destroy1(rec)
        }
    }
}
