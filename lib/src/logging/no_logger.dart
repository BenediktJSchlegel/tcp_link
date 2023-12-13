import 'package:tcp_link/src/logging/interfaces/link_logger.dart';

class NoLogger implements LinkLogger {
  @override
  void debug(String message) {
    // intentionally empty
  }

  @override
  void error(String message) {
    // intentionally empty
  }

  @override
  void info(String message) {
    // intentionally empty
  }

  @override
  void log(String message, LoggingVerbosity verbose) {
    // intentionally empty
  }
}
