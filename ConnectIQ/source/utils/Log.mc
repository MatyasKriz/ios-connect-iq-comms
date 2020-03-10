using Toybox.System;

enum {
    LOG_LEVEL_VERBOSE,
    LOG_LEVEL_DEBUG,
    LOG_LEVEL_INFO,
    LOG_LEVEL_WARNING,
    LOG_LEVEL_ERROR
}

class Log {
    private var logLevel = null;
    public function initialize(_logLevel) {
        logLevel = _logLevel;
    }

    public function verbose(message) {
        if (logLevel != null && logLevel <= LOG_LEVEL_VERBOSE) {
            System.print("VERBOSE: ");
            System.println(message);
        }
    }

    public function debug(message) {
        if (logLevel != null && logLevel <= LOG_LEVEL_DEBUG) {
            System.print("DEBUG: ");
            System.println(message);
        }
    }

    public function info(message) {
        if (logLevel != null && logLevel <= LOG_LEVEL_INFO) {
            System.print("INFO: ");
            System.println(message);
        }
    }

    public function warning(message) {
        if (logLevel != null && logLevel <= LOG_LEVEL_WARNING) {
            System.print("WARNING: ");
            System.println(message);
        }
    }

    public function error(message) {
        if (logLevel != null && logLevel <= LOG_LEVEL_ERROR) {
            System.print("ERROR: ");
            System.println(message);
        }
    }
}
