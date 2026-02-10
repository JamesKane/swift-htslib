import CHtslib
import CHTSlibShims

/// Iterates VCF/BCF records sequentially from an open file.
///
/// Since ``VCFRecord`` is `~Copyable`, this class cannot conform to `IteratorProtocol`.
/// Use a `while let` loop instead:
/// ```swift
/// while var record = iterator.next() {
///     try record.unpack()
///     print(record.alleles)
/// }
/// ```
public final class VCFRecordIterator {
    private let file: UnsafeMutablePointer<htsFile>
    private let header: UnsafeMutablePointer<bcf_hdr_t>
    private var record: UnsafeMutablePointer<bcf1_t>?
    private var exhausted = false

    internal init(file: UnsafeMutablePointer<htsFile>, header: UnsafeMutablePointer<bcf_hdr_t>) {
        self.file = file
        self.header = header
        self.record = bcf_init()
    }

    /// Read the next variant record.
    ///
    /// - Returns: The next ``VCFRecord``, or `nil` at end-of-file.
    public func next() -> VCFRecord? {
        guard !exhausted, let rec = record else { return nil }
        let ret = bcf_read(file, header, rec)
        if ret >= 0 {
            let result = rec
            self.record = bcf_init()
            return VCFRecord(pointer: result)
        } else {
            exhausted = true
            return nil
        }
    }

    deinit {
        if let rec = record { bcf_destroy(rec) }
    }
}
