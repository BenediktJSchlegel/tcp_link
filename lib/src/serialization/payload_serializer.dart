import 'dart:convert';
import 'dart:typed_data';

import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/payloads/responses/handshake_response_payload.dart';

class PayloadSerializer {
  Uint8List serialize(HandshakePayload payload) {
    return utf8.encode(jsonEncode(payload.toMap()));
  }

  HandshakePayload deserialize(Uint8List data) {
    return HandshakePayload.fromMap(jsonDecode(utf8.decode(data)));
  }

  Uint8List serializeResponse(HandshakeResponsePayload payload) {
    return utf8.encode(jsonEncode(payload.toMap()));
  }

  HandshakeResponsePayload deserializeResponse(Uint8List data) {
    return HandshakeResponsePayload.fromMap(jsonDecode(utf8.decode(data)));
  }
}
