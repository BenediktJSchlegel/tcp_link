import 'package:tcp_link/src/classes/data_collector.dart';
import 'package:tcp_link/src/classes/permission_request.dart';
import 'package:tcp_link/src/classes/transfer_permission_handler.dart';
import 'package:tcp_link/src/configuration/link_configuration.dart';
import 'package:tcp_link/src/connection/data_receiver.dart';
import 'package:tcp_link/src/logging/configuration/logging_configuration.dart';
import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

class LinkReceiver {
  final LinkConfiguration _configuration;
  final PayloadSerializer _serializer;
  final LinkLogger _logger;
  final TransferPermissionHandler _permissionHandler;

  DataReceiver? _receiver;
  DataCollector? _dataCollector;

  LinkReceiver({
    required void Function(PermissionRequest request) onTransferPermissionRequestedCallback,
    required LoggingConfiguration loggingConfiguration,
    required LinkConfiguration config,
  })  : _serializer = PayloadSerializer(),
        _logger = loggingConfiguration.logger,
        _permissionHandler = TransferPermissionHandler(onTransferPermissionRequestedCallback),
        _configuration = config;

  void start() {
    _startReceiving();
  }

  void stop() {
    _receiver?.close();
  }

  void _startReceiving() {
    _dataCollector = DataCollector(_configuration.bufferPath, _configuration.inactivityThreshold);

    _receiver = DataReceiver(
      _configuration.ip,
      _configuration.port,
      _serializer,
      _logger,
      _dataCollector!,
      _permissionHandler,
    );

    _receiver!.bind();
  }
}
