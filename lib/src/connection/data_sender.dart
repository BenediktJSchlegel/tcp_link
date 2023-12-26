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
import '../exceptions/failed_sending_data_exception.dart';
import '../exceptions/failed_sending_handshake_exception.dart';
import '../exceptions/handshake_ignored_exception.dart';
import '../exceptions/no_connection_exception.dart';

class DataSender {
  final Completer<DataSendResult> _completer = Completer<DataSendResult>();

  final SenderConfiguration _configuration;
  final PayloadSerializer _serializer;
  final LinkLogger _logger;

  Socket? _socket;
  Uint8List? _data;

  bool _handshakeCompleted = false;

  DataSender(this._configuration, this._serializer, this._logger);

  Future<DataSendResult> send(
    SenderTarget target,
    Uint8List data,
    ContentPayloadTypes type,
    String? filename,
  ) async {
    _data = data;

    try {
      _logger.info("Attempting to open socket at: ${target.ip}:${target.port}");

      _socket = await Socket.connect(
        target.ip,
        target.port,
        timeout: Duration(seconds: _configuration.timeout),
      );

      _logger.info("opened socket at: ${target.ip}:${target.port}");
    } on SocketException catch (_) {
      return DataSendResult.failed(NoConnectionException());
    }

    _socket!.listen(_onDataReceived);

    try {
      _logger.info("adding handshake payload: ${target.ip}:${target.port}");
      _socket!.add(_serializer.serialize(_buildPayload(type, data.length, filename)));
      _logger.info("added handshake payload: ${target.ip}:${target.port}");
    } on Object catch (_) {
      return DataSendResult.failed(FailedSendingHandshakeException());
    }

    _startTimeout();

    return _completer.future;
  }

  void _startTimeout() {
    Future.delayed(Duration(seconds: _configuration.timeout), () {
      _logger.info("attempting to hit timeout");

      if (!_handshakeCompleted) {
        _logger.info("Timeout was hit");
        _onTimeoutHit();
      }
    });
  }

  void _onTimeoutHit() {
    _logger.info("Completing socket after ignored handshake");
    _completer.complete(DataSendResult.failed(HandshakeIgnoredException()));
  }

  HandshakePayload _buildPayload(ContentPayloadTypes type, int contentLength, String? filename) {
    return HandshakePayload(
      _configuration.ip,
      type,
      contentLength,
      DateTime.now(),
      filename,
    );
  }

  void _onDataReceived(Uint8List data) {
    _logger.info("Received Response Data");

    if (!_handshakeCompleted) {
      _handshakeCompleted = true;

      _completeHandshake(data);
    }
  }

  void _completeHandshake(Uint8List data) {
    _logger.info("Attempting to complete handshake");

    final HandshakeResponsePayload response = _serializer.deserializeResponse(data);

    if (response.status == HandshakeResponseStatus.rejected) {
      _logger.info("Completing socket after rejected handshake");
      _completer.complete(DataSendResult.failed(HandshakeRejectedException()));
      return;
    }

    try {
      _socket!.add(_data!);
      _logger.info("Completing socket after success");

      _completer.complete(DataSendResult.success());
    } on Object catch (_) {
      _completer.complete(DataSendResult.failed(FailedSendingDataException()));
    }
  }

  Future<void> close() async {
    _logger.info("Closing socket");

    await _socket?.flush();
    await _socket?.close();
  }
}
