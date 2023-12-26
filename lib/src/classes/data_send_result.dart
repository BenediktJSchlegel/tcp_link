/// Result of the sending process
class DataSendResult {
  final Exception? _error;
  final bool _successful;

  /// Creates a [DataSendResult] that indicates the process failed
  DataSendResult.failed(Exception error)
      : _error = error,
        _successful = false;

  /// Creates a [DataSendResult] that indicates the process succeeded
  DataSendResult.success()
      : _error = null,
        _successful = true;

  /// Possible [Exception] thrown when sending failed
  Exception? get error => _error;

  /// If the sending process succeeded
  bool get successful => _successful;
}
