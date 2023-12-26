abstract interface class LinkLogger {
  void log(String message, LoggingVerbosity verbose);
  void error(String message);
  void info(String message);
}

enum LoggingVerbosity {
  error,
  info,
}
