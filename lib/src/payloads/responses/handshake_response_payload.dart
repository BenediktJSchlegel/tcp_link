import 'package:tcp_link/src/enums/handshake_response_status.dart';
import 'package:tcp_link/src/payloads/interfaces/response_payload.dart';

class HandshakeResponsePayload implements ResponsePayload {
  final String receiverIp;
  final HandshakeResponseStatus status;
  final DateTime timestamp;
  final DateTime timout;

  HandshakeResponsePayload(
    this.receiverIp,
    this.status,
    this.timestamp,
    this.timout,
  );
}
