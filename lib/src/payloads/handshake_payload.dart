import '../enums/content_payload_types.dart';

class HandshakePayload {
  final String senderIp;
  final ContentPayloadTypes type;
  final String? filename;
  final int contentLength;
  final DateTime timestamp;

  HandshakePayload(
    this.senderIp,
    this.type,
    this.contentLength,
    this.timestamp,
    this.filename,
  );

  HandshakePayload.fromMap(Map<String, dynamic> map)
      : senderIp = map["senderIp"],
        type = _intToPayloadType(map["type"]),
        contentLength = map["contentLength"],
        timestamp = DateTime.fromMillisecondsSinceEpoch(map["timestamp"]),
        filename = map["filename"];

  Map<String, dynamic> toMap() {
    return {
      "senderIp": senderIp,
      "type": _payloadTypeToInt(type),
      "contentLength": contentLength,
      "timestamp": timestamp.millisecondsSinceEpoch,
      "filename": filename,
    };
  }

  static int _payloadTypeToInt(ContentPayloadTypes types) {
    switch (types) {
      case ContentPayloadTypes.file:
        return 0;
      case ContentPayloadTypes.json:
        return 1;
      case ContentPayloadTypes.string:
        return 2;
    }
  }

  static ContentPayloadTypes _intToPayloadType(int val) {
    switch (val) {
      case 0:
        return ContentPayloadTypes.file;
      case 1:
        return ContentPayloadTypes.json;
      default:
        return ContentPayloadTypes.string;
    }
  }
}
