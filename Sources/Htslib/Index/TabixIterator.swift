import CHtslib
import CHTSlibShims

/// An iterator over tabix-indexed records matching a region query.
///
/// Use ``TabixIndex/query(region:file:)`` or ``TabixIndex/query(tid:start:end:file:)``
/// to create an iterator. Call ``next()`` repeatedly to retrieve matching lines.
///
/// ```swift
/// let tbx = try TabixIndex(path: "variants.vcf.gz")
/// var file = try HTSFile(path: "variants.vcf.gz", mode: "r")
/// let iter = try tbx.query(region: "chr1:1000-2000", file: &file)
/// while let line = iter.next() {
///     print(line)
/// }
/// ```
public final class TabixIterator: @unchecked Sendable {
    nonisolated(unsafe) private let file: UnsafeMutablePointer<htsFile>
    nonisolated(unsafe) private let tbx: UnsafeMutablePointer<tbx_t>
    nonisolated(unsafe) private let iter: UnsafeMutablePointer<hts_itr_t>
    nonisolated(unsafe) private var ks: kstring_t

    internal init(file: UnsafeMutablePointer<htsFile>,
                  tbx: UnsafeMutablePointer<tbx_t>,
                  iter: UnsafeMutablePointer<hts_itr_t>) {
        self.file = file
        self.tbx = tbx
        self.iter = iter
        self.ks = kstring_t(l: 0, m: 0, s: nil)
    }

    /// Retrieve the next record matching the query.
    ///
    /// - Returns: The next line as a string, or `nil` when iteration is complete.
    public func next() -> String? {
        let ret = hts_shim_tbx_itr_next(file, tbx, iter, &ks)
        guard ret >= 0 else { return nil }
        guard ks.l > 0, let s = ks.s else { return nil }
        return String(cString: s)
    }

    deinit {
        free(ks.s)
        hts_shim_tbx_itr_destroy(iter)
    }
}
