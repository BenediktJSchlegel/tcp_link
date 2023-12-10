import 'package:tcp_link/src/logging/link_logger.dart';

class PrintLogger implements LinkLogger {
  @override
  void debug(String message) {
    print("DEBUG: ${DateTime.now()} - $message");
  }

  @override
  void error(String message) {
    print("ERROR: ${DateTime.now()} - $message");
  }

  @override
  void info(String message) {
    print("INFO: ${DateTime.now()} - $message");
  }

  @override
  void log(String message, LoggingVerbosity verbose) {
    switch (verbose) {
      case LoggingVerbosity.debug:
        debug(message);
      case LoggingVerbosity.error:
        error(message);
      case LoggingVerbosity.info:
        info(message);
    }
  }
}
