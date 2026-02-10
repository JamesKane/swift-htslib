/// Errors thrown by swift-htslib operations.
public enum HTSError: Error, Sendable {
    /// A file could not be opened at the given path with the given mode.
    case openFailed(path: String, mode: String)
    /// Closing a file handle returned a non-zero error code.
    case closeFailed(code: Int32)
    /// A read operation failed with the given error code.
    case readFailed(code: Int32)
    /// A write operation failed with the given error code.
    case writeFailed(code: Int32)
    /// The file header could not be read.
    case headerReadFailed
    /// The file header could not be written.
    case headerWriteFailed
    /// An index file could not be loaded for the given path.
    case indexLoadFailed(path: String)
    /// Building an index for the given path failed with the given error code.
    case indexBuildFailed(path: String, code: Int32)
    /// Parsing failed with a descriptive message.
    case parseFailed(message: String)
    /// A seek operation failed.
    case seekFailed
    /// The end of the file was reached unexpectedly.
    case endOfFile
    /// Memory allocation failed.
    case outOfMemory
    /// An invalid argument was provided.
    case invalidArgument(message: String)
    /// The requested auxiliary tag was not found on the record.
    case tagNotFound(tag: String)
    /// A region string could not be parsed.
    case regionParseFailed(region: String)
    /// An internal htslib error occurred with the given error code.
    case `internal`(code: Int32)
}
