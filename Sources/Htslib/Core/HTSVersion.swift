import CHtslib

/// Provides the version string of the linked htslib library.
public struct HTSVersion: Sendable {
    /// The htslib version string (e.g. `"1.21"`).
    public static var version: String {
        String(cString: hts_version())
    }
}
