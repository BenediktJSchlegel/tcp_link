import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:tcp_link/src/payloads/handshake_payload.dart';

import '../enums/content_payload_types.dart';
import 'completed_data.dart';
import 'data_cache.dart';

class DataCollector {
  final Function(CompletedData data) _onDataCompleted;

  final Map<String, DataCache> _caches = <String, DataCache>{};

  DataCollector(this._onDataCompleted);

  void prime(HandshakePayload payload) {
    if (_caches.containsKey(payload.senderIp)) {
      // TODO throw better ex
      throw Exception();
    }

    _caches[payload.senderIp] = DataCache(payload);
  }

  void addData(String ip, Uint8List data) {
    if (!_caches.containsKey(ip)) {
      // TODO: throw better ex
      throw Exception();
    }

    _caches[ip]!.addData(data);

    if (_caches[ip]!.isComplete) {
      _onDataCompleted.call(_prepareData(
        _caches[ip]!.handshake,
        _caches[ip]!.bytes,
      ));
    }
  }

  bool containsIp(String ip) => _caches.containsKey(ip);

  CompletedData _prepareData(HandshakePayload handshake, Uint8List bytes) {
    switch (handshake.type) {
      case ContentPayloadTypes.string:
        return CompletedStringData(utf8.decode(bytes));
      case ContentPayloadTypes.json:
        return jsonDecode(utf8.decode(bytes));
      case ContentPayloadTypes.file:
        return CompletedFileData(
            bytes, handshake.filename ?? "unknown_file_name");
    }
  }
}
