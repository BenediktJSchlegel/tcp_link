import 'dart:typed_data';

class ReceivedFile {
  final Uint8List _bytes;
  final String _filename;

  ReceivedFile(this._bytes, this._filename);

  String get filename => _filename;

  Uint8List get bytes => _bytes;
}
