import 'dart:typed_data';

import 'package:tcp_link/src/payloads/handshake_payload.dart';

class DataCache {
  final HandshakePayload _handshake;
  final Uint8List _bytes;

  DataCache(this._handshake) : _bytes = Uint8List(_handshake.contentLength);

  void addData(Uint8List data) {
    _bytes.addAll(data);
  }

  bool get isComplete {
    return _bytes.length == handshake.contentLength;
  }

  HandshakePayload get handshake => _handshake;

  Uint8List get bytes => _bytes;
}
