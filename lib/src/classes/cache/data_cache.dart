import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/payloads/handshake_payload.dart';

import '../../stream/receive/receive_event.dart';

class DataCache {
  final StreamController<ReceiveEvent> _controller;
  final Socket _socket;
  final HandshakePayload _handshake;
  final List<int> _bytes;

  DataCache(
    this._handshake,
    this._socket,
    this._controller,
  ) : _bytes = List<int>.empty(growable: true);

  Future<void> addData(Uint8List data) async {
    _bytes.addAll(data);
  }

  bool get isComplete {
    return _bytes.length == handshake.contentLength;
  }

  HandshakePayload get handshake => _handshake;

  Uint8List get bytes => Uint8List.fromList(_bytes);

  Socket get socket => _socket;

  StreamController<ReceiveEvent> get controller => _controller;
}
