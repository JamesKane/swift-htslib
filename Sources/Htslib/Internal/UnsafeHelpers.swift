import CHtslib

@usableFromInline
internal func htsTry(_ code: Int32, or error: HTSError) throws {
    if code < 0 {
        throw error
    }
}

@usableFromInline
internal func htsTryPointer<T>(_ pointer: UnsafeMutablePointer<T>?, or error: HTSError) throws -> UnsafeMutablePointer<T> {
    guard let p = pointer else {
        throw error
    }
    return p
}
