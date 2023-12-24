import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:tcp_link/src/classes/cache/data_cache.dart';

class BufferedDataCache extends DataCache {
  late final File _file;
  late final String _filePath;

  late final Future<IOSink> _sink;

  int _dataLength;

  BufferedDataCache(super.handshake, super.socket) : _dataLength = 0;

  Future<void> open() async {
    Completer<IOSink> completer = Completer();
    _sink = completer.future;

    Directory tempDir = await getTemporaryDirectory();

    _filePath = Path.join(
      "/storage/emulated/0/Download", //tempDir.path,
      "buffer",
      handshake.timestamp.toIso8601String(),
      handshake.filename,
    );

    final file = File(_filePath.replaceAll(":", "").replaceAll(".", "").replaceAll(",", ""));
    _file = await file.create(recursive: true, exclusive: true);

    final sink = _file.openWrite(mode: FileMode.writeOnlyAppend, encoding: utf8);

    completer.complete(sink);
  }

  Future<void> close() async {
    await (await _sink).flush();
    await (await _sink).close();
  }

  @override
  Future<void> addData(Uint8List data) async {
    _dataLength += data.length;

    (await _sink).add(data);
  }

  @override
  bool get isComplete {
    return _dataLength >= handshake.contentLength;
  }

  String get filePath => _filePath;
}
