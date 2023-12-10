import 'package:flutter/widgets.dart';
import 'package:tcp_link/src/configuration/constants/default_configuration_constants.dart';

@immutable
class LinkConfiguration {
  final String _ip;
  final int _handshakePort;
  final int _contentPort;
  final Duration _handshakeTimeout;

  /// * [ip] the ip-address of the calling device
  ///
  /// * [handshakePort] the port that TCP Handshakes are performed on. Must be different from [contentPort]
  ///
  /// * [contentPort] the port that content is exchanged on. Must be different from [handshakePort]
  ///
  /// * [handshakeTimeout] the maximum amount of time the sender will attempts to establish a connection
  const LinkConfiguration({
    required String ip,
    required int handshakePort,
    required int contentPort,
    Duration? handshakeTimeout,
  })  : _ip = ip,
        _handshakeTimeout = handshakeTimeout ??
            DefaultConfigurationConstants.defaultHandshakeTimeout,
        _handshakePort = handshakePort,
        _contentPort = contentPort;

  /// * [ip] the IP-Address of the calling device
  ///
  /// * [handshakeTimeout] the maximum amount of time the sender will attempts to establish a connection
  const LinkConfiguration.defaultPorts({
    required String ip,
    Duration? handshakeTimeout,
  })  : _ip = ip,
        _handshakeTimeout = handshakeTimeout ??
            DefaultConfigurationConstants.defaultHandshakeTimeout,
        _handshakePort = DefaultConfigurationConstants.defaultHandshakePort,
        _contentPort = DefaultConfigurationConstants.defaultContentPort;

  int get contentPort => _contentPort;

  int get handshakePort => _handshakePort;

  String get ip => _ip;

  Duration get handshakeTimeout => _handshakeTimeout;
}
