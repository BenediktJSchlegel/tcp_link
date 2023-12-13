import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/classes/sender_target.dart';
import 'package:tcp_link/src/enums/content_payload_types.dart';
import 'package:tcp_link/src/enums/handshake_response_status.dart';
import 'package:tcp_link/src/exceptions/handshake_rejected_exception.dart';
import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/payloads/responses/handshake_response_payload.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

import '../classes/data_send_result.dart';
import '../configuration/sender_configuration.dart';

class DataSender {
  final SenderConfiguration _configuration;
  final PayloadSerializer _serializer;
  final LinkLogger _logger;

  Socket? _socket;
  Uint8List? _data;

  final Completer<DataSendResult> _completer = Completer<DataSendResult>();

  DataSender(this._configuration, this._serializer, this._logger);

  Future<DataSendResult> send(SenderTarget target, Uint8List data, ContentPayloadTypes type) async {
    _data = data;
    _socket = await Socket.connect(target.ip, target.port);

    _socket!.listen(_onDataReceived);

    _socket!.add(_serializer.serialize(_buildPayload(type, data.length)));

    // TODO: Test if this is how this works
    return _completer.future;
  }

  HandshakePayload _buildPayload(ContentPayloadTypes type, int contentLength) {
    return HandshakePayload(
      _configuration.ip,
      type,
      contentLength,
      DateTime.now(),
      "tempfilename",
    ); // TODO: actually pass file name
  }

  void _onDataReceived(Uint8List data) {
    // TODO:
    // if first -> send actual payload
    // if not -> ??
    final HandshakeResponsePayload response = _serializer.deserializeResponse(data);

    if (response.status == HandshakeResponseStatus.rejected) {
      _completer.complete(DataSendResult.failed(HandshakeRejectedError()));
      return;
    }

    _socket!.add(_data!);

    _completer.complete(DataSendResult.success());
  }

  void close() {
    _socket?.close();
  }
}
