import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/payloads/handshake_payload.dart';

class DataCache {
  final Socket _socket;
  final HandshakePayload _handshake;
  final List<int> _bytes;

  DataCache(this._handshake, this._socket) : _bytes = List<int>.empty(growable: true);

  Future<void> addData(Uint8List data) async {
    _bytes.addAll(data);
  }

  bool get isComplete {
    return _bytes.length == handshake.contentLength;
  }

  HandshakePayload get handshake => _handshake;

  Uint8List get bytes => Uint8List.fromList(_bytes);

  Socket get socket => _socket;
}
