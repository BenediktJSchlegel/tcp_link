import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class LinkSender {
  Socket? _socket;

  void sendFile(File file) {
    throw UnimplementedError();
  }

  void sendJson(Map<String, dynamic> data) {
    // jsonEncode -> jsonDecode
    throw UnimplementedError();
  }

  void sendString(String data) {
    throw UnimplementedError();
  }

  void close() {
    _socket!.close();
  }
}
