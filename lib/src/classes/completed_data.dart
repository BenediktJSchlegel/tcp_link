import 'dart:typed_data';

abstract interface class CompletedData {}

class CompletedFileData implements CompletedData {
  final Uint8List _bytes;
  final String _filename;

  CompletedFileData(this._bytes, this._filename);

  Uint8List get bytes => _bytes;

  String get filename => _filename;
}

class CompletedStringData implements CompletedData {
  final String _data;

  CompletedStringData(this._data);

  String get data => _data;
}

class CompletedJsonData implements CompletedData {
  final Map<String, dynamic> _json;

  CompletedJsonData(this._json);

  Map<String, dynamic> get json => _json;
}
