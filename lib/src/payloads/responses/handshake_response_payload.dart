import 'package:tcp_link/src/enums/handshake_response_status.dart';

class HandshakeResponsePayload {
  final String receiverIp;
  final HandshakeResponseStatus status;
  final DateTime timestamp;

  HandshakeResponsePayload(
    this.receiverIp,
    this.status,
    this.timestamp,
  );

  HandshakeResponsePayload.fromMap(Map<String, dynamic> map)
      : receiverIp = map["receiverIp"],
        status = _intToStatus(map["status"]),
        timestamp = DateTime.fromMillisecondsSinceEpoch(map["timestamp"]);

  Map<String, dynamic> toMap() {
    return {
      "receiverIp": receiverIp,
      "status": _statusToInt(status),
      "timestamp": timestamp.millisecondsSinceEpoch,
    };
  }

  static int _statusToInt(HandshakeResponseStatus types) {
    switch (types) {
      case HandshakeResponseStatus.ready:
        return 0;
      case HandshakeResponseStatus.rejected:
        return 1;
    }
  }

  static HandshakeResponseStatus _intToStatus(int val) {
    switch (val) {
      case 0:
        return HandshakeResponseStatus.ready;
      default:
        return HandshakeResponseStatus.rejected;
    }
  }
}
