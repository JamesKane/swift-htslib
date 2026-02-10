// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

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
