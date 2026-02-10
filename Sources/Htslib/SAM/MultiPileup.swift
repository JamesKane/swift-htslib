import CHtslib
import CHTSlibShims

// MARK: - MultiPileup Types

/// A column of multi-sample pileup data at a single genomic position.
public struct MultiPileupColumn: Sendable {
    /// Reference sequence ID.
    public let contigID: Int32
    /// 0-based position on the reference.
    public let position: Int64
    /// Per-sample pileup entries (one array per sample).
    public let sampleEntries: [[PileupEntry]]

    /// Number of samples.
    public var nSamples: Int { sampleEntries.count }

    /// Depth for a specific sample.
    ///
    /// - Parameter index: 0-based sample index.
    /// - Returns: The number of reads covering this position for the given sample.
    public func depth(forSample index: Int) -> Int {
        sampleEntries[index].count
    }

    /// Total depth across all samples.
    public var totalDepth: Int {
        sampleEntries.reduce(0) { $0 + $1.count }
    }
}

// MARK: - MultiPileupIterator

/// Iterates pileup columns across multiple SAM/BAM/CRAM files simultaneously.
///
/// Usage:
/// ```
/// let mplp = MultiPileupIterator(files: [(file1.pointer, header1.pointer),
///                                         (file2.pointer, header2.pointer)])
/// while let column = mplp.next() {
///     for s in 0..<column.nSamples {
///         print("sample \(s) depth: \(column.depth(forSample: s))")
///     }
/// }
/// ```
public final class MultiPileupIterator {
    private var mplp: OpaquePointer?
    private let nSamples: Int
    private var contextBuffer: UnsafeMutablePointer<PileupCallbackData>
    private var dataPointers: UnsafeMutablePointer<UnsafeMutableRawPointer?>

    /// Create a multi-sample pileup iterator.
    /// - Parameter files: Array of (file, header) pointer pairs, one per sample.
    public init(files: [(file: UnsafeMutablePointer<htsFile>, header: UnsafeMutablePointer<sam_hdr_t>)]) {
        nSamples = files.count

        // Allocate context structs
        contextBuffer = .allocate(capacity: nSamples)
        for (i, pair) in files.enumerated() {
            contextBuffer.advanced(by: i).initialize(to: PileupCallbackData(file: pair.file, header: pair.header))
        }

        // Create array of void* pointers to contexts
        dataPointers = .allocate(capacity: nSamples)
        for i in 0..<nSamples {
            dataPointers.advanced(by: i).initialize(to: UnsafeMutableRawPointer(contextBuffer.advanced(by: i)))
        }

        mplp = bam_mplp_init(Int32(nSamples), pileupReadCallback, dataPointers)
    }

    /// Enable overlap detection for paired-end reads.
    @discardableResult
    public func initOverlaps() -> Int32 {
        guard let mplp = mplp else { return -1 }
        return bam_mplp_init_overlaps(mplp)
    }

    /// Set the maximum number of reads to pile up at any position.
    public func setMaxDepth(_ maxcnt: Int32) {
        guard let mplp = mplp else { return }
        bam_mplp_set_maxcnt(mplp, maxcnt)
    }

    /// Reset the multi-pileup iterator.
    public func reset() {
        guard let mplp = mplp else { return }
        bam_mplp_reset(mplp)
    }

    /// Get the next multi-sample pileup column.
    public func next() -> MultiPileupColumn? {
        guard let mplp = mplp else { return nil }
        var tid: Int32 = 0
        var pos: Int64 = 0
        var nPlp = [Int32](repeating: 0, count: nSamples)
        var plpPtrs = [UnsafePointer<bam_pileup1_t>?](repeating: nil, count: nSamples)

        let ret = nPlp.withUnsafeMutableBufferPointer { nBuf in
            plpPtrs.withUnsafeMutableBufferPointer { pBuf in
                bam_mplp64_auto(mplp, &tid, &pos, nBuf.baseAddress!, pBuf.baseAddress!)
            }
        }
        if ret <= 0 { return nil }

        var samples: [[PileupEntry]] = []
        samples.reserveCapacity(nSamples)
        for s in 0..<nSamples {
            var entries: [PileupEntry] = []
            if let plp = plpPtrs[s], nPlp[s] > 0 {
                entries.reserveCapacity(Int(nPlp[s]))
                for i in 0..<Int(nPlp[s]) {
                    entries.append(makePileupEntry(from: plp[i]))
                }
            }
            samples.append(entries)
        }
        return MultiPileupColumn(contigID: tid, position: pos, sampleEntries: samples)
    }

    deinit {
        if let mplp = mplp { bam_mplp_destroy(mplp) }
        dataPointers.deinitialize(count: nSamples)
        dataPointers.deallocate()
        contextBuffer.deinitialize(count: nSamples)
        contextBuffer.deallocate()
    }
}
