import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/classes/data_collector.dart';
import 'package:tcp_link/src/enums/handshake_response_status.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

import '../../tcp_link.dart';
import '../classes/transfer_permission_handler.dart';
import '../payloads/handshake_payload.dart';
import '../payloads/responses/handshake_response_payload.dart';

class DataReceiver {
  final LinkLogger _logger;
  final PayloadSerializer _serializer;
  final int _port;
  final String _ip;
  final DataCollector _collector;
  final TransferPermissionHandler _permissionHandler;

  ServerSocket? _socket;

  DataReceiver(
    this._ip,
    this._port,
    this._serializer,
    this._logger,
    this._collector,
    this._permissionHandler,
  );

  void bind() async {
    if (_socketIsOpen()) {
      close();
    }

    // TODO: Handle error thrown when binding
    _logger.info("binding to port: $_port");
    _socket = await ServerSocket.bind(_ip, _port);
    _logger.info("bound to port: $_port");

    _socket!.listen(
      _handleClientConnected,
      onDone: _handleOnDone,
      onError: _handleError,
      cancelOnError: false,
    );
  }

  void close() async {
    if (_socketIsOpen()) {
      _logger.info("closing handshake receiver");

      await _socket!.close();

      _socket = null;
    }
  }

  void _handleError(Object error, StackTrace trace) {
    _logger.error(error.toString());
    // TODO: Error handling
  }

  void _handleOnDone() {
    _logger.info("on done triggered");
    // TODO: Do something here?
  }

  void _handleClientConnected(Socket client) {
    client.listen((Uint8List data) => _handleDataReceived(client, data));
  }

  void _handleDataReceived(Socket client, Uint8List data) {
    _logger.info("received data");

    if (!_collector.containsIp(client.remoteAddress.address)) {
      _handleHandshake(client, data);
    } else {
      _handleData(client, data);
    }
  }

  void _handleData(Socket client, Uint8List data) {
    _collector.addData(client.remoteAddress.address, data);

    // TODO: Handle error when adding response
    client.add(utf8.encode("next"));

    _logger.info("sent response");
  }

  void _handleHandshake(Socket client, Uint8List data) {
    // TODO: Handle error while deserializing
    HandshakePayload payload = _serializer.deserialize(data);

    if (!_permissionHandler.getPermission(payload)) {
      client.add(_serializer.serializeResponse(_generateResponse(HandshakeResponseStatus.rejected)));

      return;
    }

    client.add(_serializer.serializeResponse(_generateResponse(HandshakeResponseStatus.ready)));

    _collector.prime(payload);
  }

  HandshakeResponsePayload _generateResponse(HandshakeResponseStatus status) {
    return HandshakeResponsePayload(
      _ip,
      status,
      DateTime.now(),
    );
  }

  bool _socketIsOpen() {
    return _socket != null;
  }
}
