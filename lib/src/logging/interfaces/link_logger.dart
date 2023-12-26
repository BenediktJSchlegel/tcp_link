/// Interface for Logging within the tcp_link library. May be implemented for custom logging
abstract interface class LinkLogger {
  /// Logs the [message] using the LoggingVerbosity [verbose]
  void log(String message, LoggingVerbosity verbose);

  // Logs the [message] with `error` verbosity
  void error(String message);

  // Logs the [message] with `info` verbosity
  void info(String message);
}

/// Verbosity Levels of the logger
enum LoggingVerbosity {
  error,
  info,
}
