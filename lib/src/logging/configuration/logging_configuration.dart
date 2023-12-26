import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/logging/no_logger.dart';
import 'package:tcp_link/src/logging/print_logger.dart';

class LoggingConfiguration {
  final LinkLogger _logger;

  /// Creates a LoggingConfiguration that defines no logger
  LoggingConfiguration.none() : _logger = NoLogger();

  /// Creates a LoggingConfiguration that defines a basic print logger
  LoggingConfiguration.print(LoggingVerbosity verbosity) : _logger = PrintLogger(verbosity);

  /// Creates a LoggingConfiguration using the given [customLogger]
  LoggingConfiguration.custom(LoggingVerbosity verbosity, LinkLogger customLogger)
      : _logger = customLogger;

  /// The logger used within the library
  LinkLogger get logger => _logger;
}
