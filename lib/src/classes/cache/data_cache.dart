import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/stream/receive/failed_receive_event.dart';

import '../../stream/receive/receive_event.dart';

class DataCache {
  final StreamController<ReceiveEvent> _controller;
  final Socket _socket;
  final HandshakePayload _handshake;
  final List<int> _bytes;
  final Function(DataCache cache, ReceiveEvent event) _onTimeout;
  final int _inactivityThreshold;

  Timer? _timer;

  @protected
  DateTime? lastActivity;

  DataCache(
    this._handshake,
    this._socket,
    this._controller,
    this._onTimeout,
    this._inactivityThreshold,
  ) : _bytes = List<int>.empty(growable: true) {
    _timer = Timer.periodic(const Duration(seconds: 3), _checkAbandonment);
    lastActivity = DateTime.now();
  }

  void _checkAbandonment(Timer timer) {
    if (lastActivity != null &&
        DateTime.now().difference(lastActivity!).inSeconds >= _inactivityThreshold) {
      _onTimeout.call(this, FailedReceiveEvent());
    }
  }

  Future<void> addData(Uint8List data) async {
    lastActivity = DateTime.now();

    _bytes.addAll(data);
  }

  bool get isComplete {
    return _bytes.length == handshake.contentLength;
  }

  HandshakePayload get handshake => _handshake;

  Uint8List get bytes => Uint8List.fromList(_bytes);

  Socket get socket => _socket;

  StreamController<ReceiveEvent> get controller => _controller;

  Function get onTimeout => _onTimeout;

  void close() {
    _timer?.cancel();
    _controller.close();
    _socket.destroy();
  }
}
