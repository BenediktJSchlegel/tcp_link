import 'dart:typed_data';

class ReceivedFile {
  final String _tempFilePath;
  final String _filename;

  ReceivedFile(this._tempFilePath, this._filename);

  String get filename => _filename;

  String get tempFilePath => _tempFilePath;
}
