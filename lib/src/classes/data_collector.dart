import 'dart:async';
import 'dart:convert';
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

  final String _bufferDir;
  final int _inactivityThreshold;

  DataCollector(this._bufferDir, this._inactivityThreshold);

  Future<void> prime(
      HandshakePayload payload, Socket socket, StreamController<ReceiveEvent> controller) async {
    if (_caches.containsKey(payload.senderIp)) {
      // Cache is already initialized. This is very likely an error and should not happen!
      // TODO: LOG
      return;
    }

    if (payload.type == ContentPayloadTypes.file) {
      final bufferedCache = BufferedDataCache(
        payload,
        socket,
        controller,
        _closeCache,
        _inactivityThreshold,
      );

      await bufferedCache.open(_bufferDir);

      _caches[payload.senderIp] = bufferedCache;

      // TODO: LOG
    } else {
      _caches[payload.senderIp] = DataCache(
        payload,
        socket,
        controller,
        _closeCache,
        _inactivityThreshold,
      );

      // TODO: LOG
    }
  }

  Future<void> addData(String ip, Uint8List data) async {
    if (!_caches.containsKey(ip)) {
      return;
    }

    // TODO: LOG
    await _caches[ip]!.addData(data);

    if (_caches[ip]!.isComplete) {
      // TODO: LOG
      _closeCache(_caches[ip]!, DoneReceiveEvent(_prepareData(_caches[ip]!)));
    }
  }

  void _closeCache(DataCache cache, ReceiveEvent event) {
    // TODO: LOG
    cache.controller.add(event);
    cache.close();

    _eject(cache.handshake.senderIp);
  }

  void _eject(String ip) {
    // TODO: LOG
    _caches.removeWhere((key, value) => key == ip);
  }

  bool containsIp(String ip) => _caches.containsKey(ip);

  CompletedData _prepareData(DataCache cache) {
    // TODO: LOG
    switch (cache.handshake.type) {
      case ContentPayloadTypes.string:
        return CompletedStringData(utf8.decode(cache.bytes));
      case ContentPayloadTypes.json:
        return jsonDecode(utf8.decode(cache.bytes));
      case ContentPayloadTypes.file:
        return CompletedFileData((cache as BufferedDataCache).filePath, cache.absolutePath);
    }
  }
}
