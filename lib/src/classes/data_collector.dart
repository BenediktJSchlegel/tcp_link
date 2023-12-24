import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/classes/cache/buffered_data_cache.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';

import '../enums/content_payload_types.dart';
import 'completed_data.dart';
import 'cache/data_cache.dart';

class DataCollector {
  final Function(CompletedData data) _onDataCompleted;

  final Map<String, DataCache> _caches = <String, DataCache>{};

  DataCollector(this._onDataCompleted);

  Future<void> prime(HandshakePayload payload, Socket socket) async {
    if (_caches.containsKey(payload.senderIp)) {
      // TODO throw better ex
      throw Exception();
    }

    if (payload.type == ContentPayloadTypes.file) {
      final bufferedCache = BufferedDataCache(payload, socket);
      await bufferedCache.open();

      _caches[payload.senderIp] = bufferedCache;
    } else {
      _caches[payload.senderIp] = DataCache(payload, socket);
    }
  }

  Future<void> addData(String ip, Uint8List data) async {
    if (!_caches.containsKey(ip)) {
      // TODO: throw better ex
      throw Exception();
    }

    await _caches[ip]!.addData(data);

    if (_caches[ip]!.isComplete) {
      _onDataCompleted.call(_prepareData(_caches[ip]!));
      _caches[ip]?.socket.destroy();

      if (_caches[ip] is BufferedDataCache) {
        (_caches[ip] as BufferedDataCache).close();
      }

      _eject(ip);
    }
  }

  void _eject(String ip) {
    _caches.removeWhere((key, value) => key == ip);
  }

  bool containsIp(String ip) => _caches.containsKey(ip);

  CompletedData _prepareData(DataCache cache) {
    switch (cache.handshake.type) {
      case ContentPayloadTypes.string:
        return CompletedStringData(utf8.decode(cache.bytes));
      case ContentPayloadTypes.json:
        return jsonDecode(utf8.decode(cache.bytes));
      case ContentPayloadTypes.file:
        return CompletedFileData(
            (cache as BufferedDataCache).filePath, cache.handshake.filename ?? "unknown_file_name");
    }
  }
}
