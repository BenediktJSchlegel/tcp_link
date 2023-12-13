import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class DataSerializer {
  Future<Uint8List> serializeFile(File file) async {
    return await file.readAsBytes();
  }

  Uint8List serializeString(String data) {
    return utf8.encode(data);
  }

  Uint8List serializeMap(Map<String, dynamic> data) {
    return utf8.encode(jsonEncode(data));
  }
}
