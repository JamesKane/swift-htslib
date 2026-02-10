public enum HTSError: Error, Sendable {
    case openFailed(path: String, mode: String)
    case closeFailed(code: Int32)
    case readFailed(code: Int32)
    case writeFailed(code: Int32)
    case headerReadFailed
    case headerWriteFailed
    case indexLoadFailed(path: String)
    case indexBuildFailed(path: String, code: Int32)
    case parseFailed(message: String)
    case seekFailed
    case endOfFile
    case outOfMemory
    case invalidArgument(message: String)
    case tagNotFound(tag: String)
    case regionParseFailed(region: String)
    case `internal`(code: Int32)
}
