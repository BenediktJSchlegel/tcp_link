import '../enums/content_payload_types.dart';

/// Payload Object sent by the Sender when trying to establish a connection
class HandshakePayload {
  /// Ip of the sender
  final String senderIp;

  /// Type of content the sender wants to send
  final ContentPayloadTypes type;

  /// Filename of the file the sender wants to send. Is null if [type] is not [ContentPayloadTypes.file]
  final String? filename;

  /// Length of the content the sender wants to send
  final int contentLength;

  /// Timestamp at which the [HandshakePayload] was generated
  final DateTime timestamp;

  /// Creates a new [HandshakePayload]
  HandshakePayload(
    this.senderIp,
    this.type,
    this.contentLength,
    this.timestamp,
    this.filename,
  );

  /// Converts the [map] to a [HandshakePayload]
  HandshakePayload.fromMap(Map<String, dynamic> map)
      : senderIp = map["senderIp"],
        type = _intToPayloadType(map["type"]),
        contentLength = map["contentLength"],
        timestamp = DateTime.fromMillisecondsSinceEpoch(map["timestamp"]),
        filename = map["filename"];

  /// Converts this [HandshakePayload] to a [Map]
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
