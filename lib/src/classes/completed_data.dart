/// Base [CompletedData]. See [CompletedFileData], [CompletedStringData] and [CompletedJsonData]
abstract interface class CompletedData {}

/// Completed data object for a file
class CompletedFileData implements CompletedData {
  final String _tempFilePath;
  final String _filename;

  CompletedFileData(this._tempFilePath, this._filename);

  /// The path to which the file was buffered
  String get tempFilePath => _tempFilePath;

  /// The name of the file
  String get filename => _filename;
}

/// Completed data object for a string
class CompletedStringData implements CompletedData {
  final String _data;

  CompletedStringData(this._data);

  /// The data payload
  String get data => _data;
}

/// Completed data object for json
class CompletedJsonData implements CompletedData {
  final Map<String, dynamic> _json;

  CompletedJsonData(this._json);

  /// The json payload
  Map<String, dynamic> get json => _json;
}
