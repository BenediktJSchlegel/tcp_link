class SenderConfiguration {
  final String _ip;
  final int _timeout;

  /// Creates a configuration for the sender component. [ip] defines the IP of the sending device. [timeout] defines
  /// the amount of seconds it takes for a connection to be abandoned.
  SenderConfiguration(this._ip, this._timeout);

  /// The IP of the sending device
  String get ip => _ip;

  /// The amount of seconds it takes for a connection to be abandoned
  int get timeout => _timeout;
}
