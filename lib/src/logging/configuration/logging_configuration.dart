import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/logging/no_logger.dart';
import 'package:tcp_link/src/logging/print_logger.dart';

class LoggingConfiguration {
  final LinkLogger _logger;
  final LoggingVerbosity _verbosity;

  LoggingConfiguration.none()
      : _logger = NoLogger(),
        _verbosity = LoggingVerbosity.error;
  LoggingConfiguration.print(LoggingVerbosity verbosity)
      : _logger = PrintLogger(verbosity),
        _verbosity = verbosity;
  LoggingConfiguration.custom(LoggingVerbosity verbosity, LinkLogger customLogger)
      : _logger = customLogger,
        _verbosity = verbosity;

  LinkLogger get logger => _logger;
}
