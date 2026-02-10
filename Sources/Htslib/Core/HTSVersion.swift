import CHtslib

public struct HTSVersion: Sendable {
    public static var version: String {
        String(cString: hts_version())
    }
}
