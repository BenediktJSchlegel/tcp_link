import 'package:tcp_link/src/payloads/interfaces/payload.dart';

import '../enums/content_payload_types.dart';

class HandshakePayload implements Payload {
  final String senderIp;
  final ContentPayloadTypes type;
  final int contentLength;
  final DateTime timestamp;

  HandshakePayload(
    this.senderIp,
    this.type,
    this.contentLength,
    this.timestamp,
  );
}
