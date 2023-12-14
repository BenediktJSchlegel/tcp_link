class SenderConfiguration {
  final String _ip;
  final int _timeout;

  SenderConfiguration(this._ip, this._timeout);

  String get ip => _ip;

  int get timeout => _timeout;
}
