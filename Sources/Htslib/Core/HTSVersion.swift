// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib

/// Provides the version string of the linked htslib library.
public struct HTSVersion: Sendable {
    /// The htslib version string (e.g. `"1.21"`).
    public static var version: String {
        String(cString: hts_version())
    }
}
