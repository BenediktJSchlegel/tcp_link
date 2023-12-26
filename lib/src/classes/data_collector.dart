import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tcp_link/src/classes/cache/buffered_data_cache.dart';
import 'package:tcp_link/src/logging/interfaces/link_logger.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/stream/receive/done_receive_event.dart';

import '../enums/content_payload_types.dart';
import '../stream/receive/receive_event.dart';
import 'completed_data.dart';
import 'cache/data_cache.dart';

class DataCollector {
  final LinkLogger _logger;
  final Map<String, DataCache> _caches = <String, DataCache>{};

  final String _bufferDir;
  final int _inactivityThreshold;

  DataCollector(this._logger, this._bufferDir, this._inactivityThreshold);

  Future<void> prime(
      HandshakePayload payload, Socket socket, StreamController<ReceiveEvent> controller) async {
    if (_caches.containsKey(payload.senderIp)) {
      // Cache is already initialized. This is very likely an error and should not happen!
      _logger.error(
          "Tried priming DataCollector with IP: ${payload.senderIp} which was already present");
      return;
    }

    _logger.info("Attempting to prime DataCollector with IP: ${payload.senderIp}");

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

      _logger.info("Added BufferedDataCache for: ${payload.senderIp}");
    } else {
      _caches[payload.senderIp] = DataCache(
        payload,
        socket,
        controller,
        _closeCache,
        _inactivityThreshold,
      );

      _logger.info("Added DataCache for: ${payload.senderIp}");
    }
  }

  Future<void> addData(String ip, Uint8List data) async {
    if (!_caches.containsKey(ip)) {
      return;
    }

    _logger.info("Adding data for: $ip");

    await _caches[ip]!.addData(data);

    if (_caches[ip]!.isComplete) {
      _logger.info("Completed data for: $ip");
      _closeCache(_caches[ip]!, DoneReceiveEvent(_prepareData(_caches[ip]!)));
    }
  }

  void _closeCache(DataCache cache, ReceiveEvent event) {
    _logger.info("Closing cache for: ${cache.handshake.senderIp}");

    cache.controller.add(event);
    cache.close();

    _eject(cache.handshake.senderIp);

    _logger.info("Finished closing cache for: ${cache.handshake.senderIp}");
  }

  void _eject(String ip) {
    _logger.info("Ejecting DataCache for: $ip");

    _caches.removeWhere((key, value) => key == ip);
  }

  bool containsIp(String ip) => _caches.containsKey(ip);

  CompletedData _prepareData(DataCache cache) {
    switch (cache.handshake.type) {
      case ContentPayloadTypes.string:
        _logger.info("Converting Data into String");
        return CompletedStringData(utf8.decode(cache.bytes));
      case ContentPayloadTypes.json:
        _logger.info("Converting Data into Json");
        return jsonDecode(utf8.decode(cache.bytes));
      case ContentPayloadTypes.file:
        _logger.info("Converting Data into File");
        return CompletedFileData((cache as BufferedDataCache).filePath, cache.absolutePath);
    }
  }
}
