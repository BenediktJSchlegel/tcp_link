import 'package:tcp_link/src/classes/completed_data.dart';
import 'package:tcp_link/src/classes/data_collector.dart';
import 'package:tcp_link/src/classes/received_file.dart';
import 'package:tcp_link/src/classes/transfer_permission_handler.dart';
import 'package:tcp_link/src/configuration/link_configuration.dart';
import 'package:tcp_link/src/connection/data_receiver.dart';
import 'package:tcp_link/src/logging/link_logger.dart';
import 'package:tcp_link/src/logging/print_logger.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

class LinkReceiver {
  final Function(String data) onStringReceived;
  final Function(Map<String, dynamic> json) onJsonReceived;
  final Function(ReceivedFile file) onFileReceived;

  final LinkConfiguration _configuration;
  final PayloadSerializer _serializer;
  final LinkLogger _logger;
  final TransferPermissionHandler _permissionHandler;

  DataReceiver? _handshakeReceiver;
  DataCollector? _dataCollector;

  // TODO: inject logger
  LinkReceiver({
    required LinkConfiguration config,
    required this.onStringReceived,
    required this.onJsonReceived,
    required this.onFileReceived,
  })  : _serializer = PayloadSerializer(),
        _logger = PrintLogger(),
        _permissionHandler = TransferPermissionHandler(),
        _configuration = config;

  void start() {
    _startReceiving();
  }

  void stop() {
    _handshakeReceiver?.close();
  }

  void _startReceiving() {
    _dataCollector = DataCollector(_onDataCompleted);

    _handshakeReceiver = DataReceiver(
      _configuration.ip,
      _configuration.handshakePort,
      _serializer,
      _logger,
      _dataCollector!,
      _permissionHandler,
    );

    _handshakeReceiver!.bind();
  }

  void _onDataCompleted(CompletedData data) {}
}
