import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/classes/data_send_result.dart';
import 'package:tcp_link/src/classes/sender_target.dart';
import 'package:tcp_link/src/configuration/sender_configuration.dart';
import 'package:tcp_link/src/connection/data_sender.dart';
import 'package:tcp_link/src/enums/content_payload_types.dart';
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
    return _sendData(target, await _serializer.serializeFile(file));
  }

  Future<DataSendResult> sendMap(SenderTarget target, Map<String, dynamic> data) async {
    return _sendData(target, _serializer.serializeMap(data));
  }

  Future<DataSendResult> sendString(SenderTarget target, String data) async {
    return _sendData(target, _serializer.serializeString(data));
  }

  Future<DataSendResult> _sendData(SenderTarget target, Uint8List data) async {
    final sender = DataSender(_configuration, _payloadSerializer, _logger);

    return await (sender.send(target, data, ContentPayloadTypes.file).then((value) {
      sender.close();
      return value;
    }));
  }
}