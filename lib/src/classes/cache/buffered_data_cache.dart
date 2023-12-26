import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as Path;
import 'package:tcp_link/src/classes/cache/data_cache.dart';
import 'package:tcp_link/src/stream/receive/progress_receive_event.dart';

class BufferedDataCache extends DataCache {
  late final File _file;
  late final String _filePath;

  late final Future<IOSink> _sink;

  int _dataLength;

  BufferedDataCache(
    super.handshake,
    super.socket,
    super.controller,
    super.onTimeout,
    super._inactivityThreshold,
  ) : _dataLength = 0;

  Future<void> open(String bufferDir) async {
    Completer<IOSink> completer = Completer();
    _sink = completer.future;

    _filePath = Path.join(
      bufferDir,
      handshake.timestamp.toIso8601String(),
      handshake.filename,
    );

    final file = File(_filePath.replaceAll(":", "").replaceAll(",", ""));

    _file = await file.create(recursive: true, exclusive: true);

    final sink = _file.openWrite(mode: FileMode.writeOnlyAppend, encoding: utf8);

    completer.complete(sink);
  }

  @override
  void close() {
    super.close();

    _closeSink();
  }

  Future<void> _closeSink() async {
    await (await _sink).flush();
    await (await _sink).close();
  }

  @override
  Future<void> addData(Uint8List data) async {
    lastActivity = DateTime.now();

    _dataLength += data.length;

    controller.add(ProgressReceiveEvent(_dataLength, handshake.contentLength));

    (await _sink).add(data);
  }

  @override
  bool get isComplete {
    return _dataLength >= handshake.contentLength;
  }

  String get filePath => _filePath;

  String get absolutePath => _file.absolute.path;
}
