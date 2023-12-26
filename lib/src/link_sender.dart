import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';

import 'package:tcp_link/src/connection/data_sender.dart';
import 'package:tcp_link/src/serialization/data_serializer.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

import '../tcp_link.dart';

class LinkSender {
  final DataSerializer _serializer;
  final SenderConfiguration _configuration;
  final PayloadSerializer _payloadSerializer;
  final LinkLogger _logger;

  LinkSender({
    required LoggingConfiguration loggingConfiguration,
    required SenderConfiguration configuration,
  })  : _serializer = DataSerializer(),
        _logger = loggingConfiguration.logger,
        _payloadSerializer = PayloadSerializer(),
        _configuration = configuration;

  Future<DataSendResult> sendFile(SenderTarget target, File file) async {
    return _sendData(
      target,
      await _serializer.serializeFile(file),
      ContentPayloadTypes.file,
      basename(file.path),
    );
  }

  Future<DataSendResult> sendMap(SenderTarget target, Map<String, dynamic> data) async {
    return _sendData(
      target,
      _serializer.serializeMap(data),
      ContentPayloadTypes.json,
    );
  }

  Future<DataSendResult> sendString(SenderTarget target, String data) async {
    return _sendData(
      target,
      _serializer.serializeString(data),
      ContentPayloadTypes.string,
    );
  }

  Future<DataSendResult> _sendData(SenderTarget target, Uint8List data, ContentPayloadTypes type,
      [String? filename]) async {
    final sender = DataSender(_configuration, _payloadSerializer, _logger);

    return await (sender.send(target, data, type, filename).then((value) async {
      await sender.close();
      return value;
    }));
  }
}
