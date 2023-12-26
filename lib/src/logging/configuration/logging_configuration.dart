import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/logging/no_logger.dart';
import 'package:tcp_link/src/logging/print_logger.dart';

class LoggingConfiguration {
  final LinkLogger _logger;
  final LoggingVerbosity _verbosity;

  /// Creates a LoggingConfiguration that defines no logger
  LoggingConfiguration.none()
      : _logger = NoLogger(),
        _verbosity = LoggingVerbosity.error;

  /// Creates a LoggingConfiguration that defines a basic print logger
  LoggingConfiguration.print(LoggingVerbosity verbosity)
      : _logger = PrintLogger(verbosity),
        _verbosity = verbosity;

  /// Creates a LoggingConfiguration using the given [customLogger]
  LoggingConfiguration.custom(LoggingVerbosity verbosity, LinkLogger customLogger)
      : _logger = customLogger,
        _verbosity = verbosity;

  /// The logger used within the library
  LinkLogger get logger => _logger;
}
