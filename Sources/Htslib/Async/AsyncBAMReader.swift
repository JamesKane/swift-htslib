import CHtslib
import CHTSlibShims

/// Actor-isolated asynchronous reader for SAM/BAM/CRAM files.
///
/// Provides async `next()` iteration with support for indexed region queries
/// and thread pools. All file I/O is serialized by the actor.
///
/// Usage:
/// ```swift
/// let reader = try AsyncBAMReader(path: "file.bam", loadIndex: true)
/// // Sequential reading
/// while let record = try await reader.next() { ... }
/// // Region query
/// try await reader.query(region: "chr1:1000-2000")
/// while let record = try await reader.next() { ... }
/// ```
public actor AsyncBAMReader {

    // MARK: - Storage

    private nonisolated(unsafe) let filePointer: UnsafeMutablePointer<htsFile>

    /// The SAM header — accessible without `await`.
    public nonisolated let header: SAMHeader

    /// The file path — accessible without `await`.
    public nonisolated let path: String

    // Record buffer for reading
    private nonisolated(unsafe) var record: UnsafeMutablePointer<bam1_t>?
    private var exhausted: Bool = false

    // Optional index for region queries
    private nonisolated(unsafe) var indexPointer: OpaquePointer?  // hts_idx_t*
    private nonisolated(unsafe) var queryIterator: UnsafeMutablePointer<hts_itr_t>?
    private var inQuery: Bool = false

    // Optional owned thread pool
    private nonisolated(unsafe) var ownedPool: OpaquePointer?  // hts_tpool*

    // MARK: - Initialization

    /// Open a SAM/BAM/CRAM file for async reading.
    ///
    /// - Parameters:
    ///   - path: Path to the file.
    ///   - loadIndex: If `true`, load the associated index (required for region queries).
    /// - Throws: `HTSError.openFailed` if the file cannot be opened,
    ///           `HTSError.headerReadFailed` if the header cannot be read,
    ///           `HTSError.indexLoadFailed` if `loadIndex` is true and the index is missing.
    public init(path: String, loadIndex: Bool = false) throws {
        guard let fp = hts_open(path, "r") else {
            throw HTSError.openFailed(path: path, mode: "r")
        }
        self.filePointer = fp
        self.path = path

        guard let hdr = sam_hdr_read(fp) else {
            hts_close(fp)
            throw HTSError.headerReadFailed
        }
        self.header = SAMHeader(pointer: hdr)

        self.record = bam_init1()

        if loadIndex {
            guard let idx = sam_index_load(fp, path) else {
                bam_destroy1(self.record!)
                hts_close(fp)
                throw HTSError.indexLoadFailed(path: path)
            }
            self.indexPointer = idx
        }
    }

    /// Open a SAM/BAM/CRAM file for async reading with a dedicated thread pool.
    ///
    /// - Parameters:
    ///   - path: Path to the file.
    ///   - loadIndex: If `true`, load the associated index.
    ///   - threads: Number of threads for the owned pool.
    public init(path: String, loadIndex: Bool = false, threads: Int32) throws {
        guard let fp = hts_open(path, "r") else {
            throw HTSError.openFailed(path: path, mode: "r")
        }
        self.filePointer = fp
        self.path = path

        guard let hdr = sam_hdr_read(fp) else {
            hts_close(fp)
            throw HTSError.headerReadFailed
        }
        self.header = SAMHeader(pointer: hdr)

        self.record = bam_init1()

        if loadIndex {
            guard let idx = sam_index_load(fp, path) else {
                bam_destroy1(self.record!)
                hts_close(fp)
                throw HTSError.indexLoadFailed(path: path)
            }
            self.indexPointer = idx
        }

        // Create and attach owned thread pool
        guard let pool = hts_tpool_init(threads) else {
            if let idx = self.indexPointer { hts_idx_destroy(idx) }
            bam_destroy1(self.record!)
            hts_close(fp)
            throw HTSError.outOfMemory
        }
        self.ownedPool = pool
        var tp = htsThreadPool(pool: pool, qsize: 0)
        hts_set_thread_pool(fp, &tp)
    }

    deinit {
        if let iter = queryIterator { hts_itr_destroy(iter) }
        if let idx = indexPointer { hts_idx_destroy(idx) }
        if let rec = record { bam_destroy1(rec) }
        if let pool = ownedPool { hts_tpool_destroy(pool) }
        hts_close(filePointer)
    }

    // MARK: - Reading

    /// Read the next record.
    ///
    /// In sequential mode, reads the next record from the file.
    /// After `query(region:)` is called, reads the next record in the queried region.
    ///
    /// - Returns: The next `BAMRecord`, or `nil` at end-of-file/region.
    /// - Throws: `HTSError.readFailed` on I/O error.
    public func next() throws -> BAMRecord? {
        guard !exhausted, let rec = record else { return nil }

        let ret: Int32
        if inQuery, let iter = queryIterator {
            ret = hts_shim_sam_itr_next(filePointer, iter, rec)
        } else {
            ret = sam_read1(filePointer, header.pointer, rec)
        }

        if ret >= 0 {
            let result = rec
            self.record = bam_init1()
            return BAMRecord(pointer: result)
        } else if ret == -1 {
            exhausted = true
            return nil
        } else {
            exhausted = true
            throw HTSError.readFailed(code: ret)
        }
    }

    // MARK: - Region Queries

    /// Start a region query using a string like "chr1:1000-2000".
    ///
    /// Subsequent calls to `next()` return only records overlapping the region.
    /// Requires that the reader was opened with `loadIndex: true`.
    ///
    /// - Parameter region: Region string (e.g. "chr1", "chr1:1000-2000").
    /// - Throws: `HTSError.invalidArgument` if no index is loaded,
    ///           `HTSError.regionParseFailed` if the region cannot be parsed.
    public func query(region: String) throws {
        guard let idx = indexPointer else {
            throw HTSError.invalidArgument(message: "No index loaded; open with loadIndex: true")
        }

        // Destroy previous query iterator if any
        if let iter = queryIterator {
            hts_itr_destroy(iter)
            self.queryIterator = nil
        }

        guard let iter = sam_itr_querys(idx, header.pointer, region) else {
            throw HTSError.regionParseFailed(region: region)
        }

        self.queryIterator = iter
        self.inQuery = true
        self.exhausted = false
    }

    /// Start a region query by numeric tid, start, and end.
    ///
    /// - Parameters:
    ///   - tid: Reference sequence ID.
    ///   - start: 0-based start position.
    ///   - end: 0-based exclusive end position.
    /// - Throws: `HTSError.invalidArgument` if no index is loaded.
    public func query(tid: Int32, start: Int64, end: Int64) throws {
        guard let idx = indexPointer else {
            throw HTSError.invalidArgument(message: "No index loaded; open with loadIndex: true")
        }

        if let iter = queryIterator {
            hts_itr_destroy(iter)
            self.queryIterator = nil
        }

        guard let iter = sam_itr_queryi(idx, tid, start, end) else {
            throw HTSError.regionParseFailed(region: "\(tid):\(start)-\(end)")
        }

        self.queryIterator = iter
        self.inQuery = true
        self.exhausted = false
    }

    /// Reset the reader to sequential mode, abandoning any active region query.
    public func resetQuery() {
        if let iter = queryIterator {
            hts_itr_destroy(iter)
            self.queryIterator = nil
        }
        self.inQuery = false
        self.exhausted = false
    }

    // MARK: - Threading

    /// Set the number of threads for this file's I/O.
    ///
    /// - Parameter n: Number of additional threads.
    /// - Returns: 0 on success, negative on failure.
    @discardableResult
    public func setThreads(_ n: Int32) -> Int32 {
        hts_set_threads(filePointer, n)
    }
}
