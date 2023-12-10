import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/payloads/interfaces/payload.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

import '../../tcp_link.dart';
import '../payloads/handshake_payload.dart';
import '../payloads/responses/handshake_response_payload.dart';

class HandshakeReceiver {
  final LinkLogger _logger;
  final PayloadSerializer _serializer;
  final int _port;
  final String _ip;
  final HandshakeResponsePayload Function(HandshakePayload payload) _onReceived;

  ServerSocket? _socket;

  HandshakeReceiver(
    this._ip,
    this._port,
    this._onReceived,
    this._serializer,
    this._logger,
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

    // TODO: Handle error while deserializing
    Payload payload = _serializer.deserialize(data);

    if (payload is HandshakePayload) {
      // TODO: throw error -> bad payload
    }

    _logger.info("data deserialized");

    final HandshakeResponsePayload response =
        _onReceived(payload as HandshakePayload);

    _logger.info("got response");

    // TODO: Handle error when adding response
    client.add(_serializer.serialize(response));

    _logger.info("sent response");
  }

  bool _socketIsOpen() {
    return _socket != null;
  }
}
