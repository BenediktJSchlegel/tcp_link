import 'dart:convert';
import 'dart:typed_data';

import 'package:tcp_link/src/enums/content_payload_types.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';

import '../payloads/interfaces/payload.dart';

class PayloadSerializer {
  Uint8List serialize(Payload payload) {
    return utf8.encode("this is a payload");
  }

  Payload deserialize(Uint8List data) {
    return HandshakePayload(
      "senderIP",
      ContentPayloadTypes.string,
      100,
      DateTime.now(),
    );
  }
}
