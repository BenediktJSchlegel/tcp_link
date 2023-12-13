import 'package:tcp_link/src/logging/interfaces/link_logger.dart';

class PrintLogger implements LinkLogger {
  final LoggingVerbosity _verbosity;

  PrintLogger(this._verbosity);

  @override
  void error(String message) {
    print("ERROR: ${DateTime.now()} - $message");
  }

  @override
  void debug(String message) {
    if (_verbosity == LoggingVerbosity.error) return;

    print("DEBUG: ${DateTime.now()} - $message");
  }

  @override
  void info(String message) {
    if (_verbosity == LoggingVerbosity.error || _verbosity == LoggingVerbosity.debug) return;
    print("INFO: ${DateTime.now()} - $message");
  }

  @override
  void log(String message, LoggingVerbosity verbose) {
    switch (verbose) {
      case LoggingVerbosity.error:
        error(message);
      case LoggingVerbosity.debug:
        debug(message);
      case LoggingVerbosity.info:
        info(message);
    }
  }
}
