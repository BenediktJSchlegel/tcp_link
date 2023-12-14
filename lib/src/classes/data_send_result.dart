class DataSendResult {
  final Exception? _error;
  final bool _successful;

  DataSendResult.failed(Exception error)
      : _error = error,
        _successful = false;

  DataSendResult.success()
      : _error = null,
        _successful = true;

  Exception? get error => _error;

  bool get successful => _successful;
}
