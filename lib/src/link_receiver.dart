import 'package:tcp_link/src/classes/completed_data.dart';
import 'package:tcp_link/src/classes/data_collector.dart';
import 'package:tcp_link/src/classes/received_file.dart';
import 'package:tcp_link/src/classes/transfer_permission_handler.dart';
import 'package:tcp_link/src/configuration/link_configuration.dart';
import 'package:tcp_link/src/connection/data_receiver.dart';
import 'package:tcp_link/src/logging/configuration/logging_configuration.dart';
import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

class LinkReceiver {
  final void Function(String data)? _onStringReceived;
  final void Function(Map<String, dynamic> json)? _onJsonReceived;
  final void Function(ReceivedFile file)? _onFileReceived;

  final LinkConfiguration _configuration;
  final PayloadSerializer _serializer;
  final LinkLogger _logger;
  final TransferPermissionHandler _permissionHandler;

  DataReceiver? _handshakeReceiver;
  DataCollector? _dataCollector;

  LinkReceiver({
    required Future<bool> Function(HandshakePayload payload) onTransferPermissionRequestedCallback,
    required LoggingConfiguration loggingConfiguration,
    required LinkConfiguration config,
    required void Function(String)? onStringReceived,
    required void Function(Map<String, dynamic>)? onJsonReceived,
    required void Function(ReceivedFile)? onFileReceived,
  })  : _onFileReceived = onFileReceived,
        _onJsonReceived = onJsonReceived,
        _onStringReceived = onStringReceived,
        _serializer = PayloadSerializer(),
        _logger = loggingConfiguration.logger,
        _permissionHandler = TransferPermissionHandler(onTransferPermissionRequestedCallback),
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
      _configuration.port,
      _serializer,
      _logger,
      _dataCollector!,
      _permissionHandler,
    );

    _handshakeReceiver!.bind();
  }

  void _onDataCompleted(CompletedData data) {
    switch (data.runtimeType) {
      case CompletedFileData:
        _onFileReceived?.call(ReceivedFile((data as CompletedFileData).bytes, data.filename));
        break;
      case CompletedStringData:
        _onStringReceived?.call((data as CompletedStringData).data);
        break;
      case CompletedJsonData:
        _onJsonReceived?.call((data as CompletedJsonData).json);
        break;
    }
  }
}
