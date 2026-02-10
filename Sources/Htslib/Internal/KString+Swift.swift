// Copyright (c) 2026 James Kane. All rights reserved.
// Licensed under the BSD 3-Clause License. See LICENSE.md in the project root.

import CHtslib
import CHTSlibShims

internal extension kstring_t {
    /// Convert kstring contents to a Swift String, or nil if empty/null.
    var swiftString: String? {
        guard l > 0, let s = s else { return nil }
        return String(cString: s)
    }

    /// Create a kstring_t, perform an operation, extract the string, and free.
    static func withNew<R>(_ body: (inout kstring_t) throws -> R) rethrows -> (R, String?) {
        var ks = kstring_t()
        hts_shim_ks_initialize(&ks)
        let result = try body(&ks)
        let str = ks.swiftString
        hts_shim_ks_free(&ks)
        return (result, str)
    }
}
