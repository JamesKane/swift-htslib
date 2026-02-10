import CHtslib
import CHTSlibShims

/// Iterates all records sequentially from a SAM/BAM/CRAM file.
/// Usage: `while let record = iterator.next() { ... }`
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

/// Iterates records in a region using an index.
/// Usage: `while let record = iterator.next() { ... }`
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
