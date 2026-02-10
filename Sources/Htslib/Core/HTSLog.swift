import CHtslib

/// Control the htslib logging level.
///
/// Use ``setLevel(_:)`` and ``level`` to configure how much diagnostic
/// information htslib emits to stderr.
public enum HTSLog {
    /// Set the global htslib logging level.
    ///
    /// - Parameter level: The desired ``HTSLogLevel``.
    public static func setLevel(_ level: HTSLogLevel) {
        hts_set_log_level(level.rawValue)
    }

    /// Get the current global htslib logging level.
    public static var level: HTSLogLevel {
        HTSLogLevel(from: hts_get_log_level())
    }
}

/// htslib logging severity levels.
public enum HTSLogLevel: Sendable {
    /// All logging disabled.
    case off
    /// Log errors only.
    case error
    /// Log errors and warnings.
    case warning
    /// Log errors, warnings, and informational messages.
    case info
    /// Log errors, warnings, info, and debug messages.
    case debug
    /// Log everything including trace messages.
    case trace

    internal var rawValue: htsLogLevel {
        switch self {
        case .off: return HTS_LOG_OFF
        case .error: return HTS_LOG_ERROR
        case .warning: return HTS_LOG_WARNING
        case .info: return HTS_LOG_INFO
        case .debug: return HTS_LOG_DEBUG
        case .trace: return HTS_LOG_TRACE
        }
    }

    internal init(from raw: htsLogLevel) {
        switch raw {
        case HTS_LOG_OFF: self = .off
        case HTS_LOG_ERROR: self = .error
        case HTS_LOG_WARNING: self = .warning
        case HTS_LOG_INFO: self = .info
        case HTS_LOG_DEBUG: self = .debug
        case HTS_LOG_TRACE: self = .trace
        default: self = .warning
        }
    }
}
