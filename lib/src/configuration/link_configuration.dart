import 'package:flutter/widgets.dart';
import 'package:tcp_link/src/configuration/constants/default_configuration_constants.dart';

@immutable
class LinkConfiguration {
  final String _ip;
  final int _port;

  /// * [ip] the ip-address of the calling device
  ///
  /// * [port] the port that content is exchanged on. Must be different from [port]
  ///
  /// * [handshakeTimeout] the maximum amount of time the sender will attempts to establish a connection
  const LinkConfiguration({
    required String ip,
    required int port,
    Duration? handshakeTimeout,
  })  : _ip = ip,
        _port = port;

  /// * [ip] the IP-Address of the calling device
  const LinkConfiguration.defaultPorts({
    required String ip,
    Duration? handshakeTimeout,
  })  : _ip = ip,
        _port = DefaultConfigurationConstants.defaultHandshakePort;

  int get port => _port;

  String get ip => _ip;
}
