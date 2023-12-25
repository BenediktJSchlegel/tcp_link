import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/classes/cache/buffered_data_cache.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/stream/receive/done_receive_event.dart';

import '../enums/content_payload_types.dart';
import '../stream/receive/receive_event.dart';
import 'completed_data.dart';
import 'cache/data_cache.dart';

class DataCollector {
  final Map<String, DataCache> _caches = <String, DataCache>{};

  Future<void> prime(
      HandshakePayload payload, Socket socket, StreamController<ReceiveEvent> controller) async {
    if (_caches.containsKey(payload.senderIp)) {
      // TODO throw better ex
      throw Exception();
    }

    if (payload.type == ContentPayloadTypes.file) {
      final bufferedCache = BufferedDataCache(payload, socket, controller);
      await bufferedCache.open();

      _caches[payload.senderIp] = bufferedCache;
    } else {
      _caches[payload.senderIp] = DataCache(payload, socket, controller);
    }
  }

  Future<void> addData(String ip, Uint8List data) async {
    if (!_caches.containsKey(ip)) {
      // TODO: throw better ex
      throw Exception();
    }

    await _caches[ip]!.addData(data);

    if (_caches[ip]!.isComplete) {
      _caches[ip]!.controller.add(DoneReceiveEvent(_prepareData(_caches[ip]!)));
      _caches[ip]!.controller.close();
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
