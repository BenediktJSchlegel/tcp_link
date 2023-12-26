abstract interface class CompletedData {}

class CompletedFileData implements CompletedData {
  final String _tempFilePath;
  final String _filename;

  CompletedFileData(this._tempFilePath, this._filename);

  String get tempFilePath => _tempFilePath;

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
