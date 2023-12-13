class DataSendResult {
  final Error? _error;
  final bool _successful;

  DataSendResult.failed(Error error)
      : _error = error,
        _successful = false;

  DataSendResult.success()
      : _error = null,
        _successful = true;

  Error? get error => _error;

  bool get successful => _successful;
}
