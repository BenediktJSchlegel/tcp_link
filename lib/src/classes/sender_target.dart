class SenderTarget {
  final int _port;
  final String _ip;

  SenderTarget(this._ip, this._port);

  String get ip => _ip;

  int get port => _port;
}
