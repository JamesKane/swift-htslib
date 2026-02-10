// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import Foundation

func testDataPath(_ filename: String) -> String {
    Bundle.module.url(forResource: "TestData", withExtension: nil)!
        .appendingPathComponent(filename).path
}

func tempFilePath(_ name: String) -> String {
    NSTemporaryDirectory() + "/swift-htslib-test-" + name
}
