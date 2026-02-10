import Testing
@testable import Htslib

@Suite("HTSVersion")
struct HTSVersionTests {
    @Test func versionStringIsNonEmpty() {
        let version = HTSVersion.version
        #expect(!version.isEmpty)
    }

    @Test func versionContainsDot() {
        let version = HTSVersion.version
        #expect(version.contains("."))
    }
}
