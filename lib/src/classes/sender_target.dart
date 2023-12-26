/// Representation of the target of a sending process
class SenderTarget {
  final int _port;
  final String _ip;

  /// Creates a new [SenderTarget] using the given target [ip] and [port]
  SenderTarget(this._ip, this._port);

  /// The target ip
  String get ip => _ip;

  /// The target port
  int get port => _port;
}
