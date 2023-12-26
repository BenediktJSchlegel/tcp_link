import 'package:flutter/widgets.dart';
import 'package:tcp_link/src/configuration/constants/default_configuration_constants.dart';

@immutable
class LinkConfiguration {
  final String _ip;
  final int _port;
  final String _bufferPath;
  final int _inactivityThreshold;

  /// * [ip] the ip-address of the calling device
  ///
  /// * [port] the port that content is exchanged on. Must be different from [port]
  ///
  /// * [handshakeTimeout] the maximum amount of time the sender will attempts to establish a connection
  ///
  /// * [bufferPath] the path to which files are buffered
  ///
  /// * [inactivityThreshold] amount of seconds it takes for a connection to be considered abandoned
  const LinkConfiguration({
    required String ip,
    required int port,
    required String bufferPath,
    int inactivityThreshold = 5,
    Duration? handshakeTimeout,
  })  : _ip = ip,
        _port = port,
        _bufferPath = bufferPath,
        _inactivityThreshold = inactivityThreshold;

  /// * [ip] the IP-Address of the calling device
  ///
  /// * [bufferPath] the path to which files are buffered
  ///
  /// * [inactivityThreshold] amount of seconds it takes for a connection to be considered abandoned
  const LinkConfiguration.defaultPorts({
    required String ip,
    required String bufferPath,
    int inactivityThreshold = 5,
    Duration? handshakeTimeout,
  })  : _ip = ip,
        _port = DefaultConfigurationConstants.defaultHandshakePort,
        _bufferPath = bufferPath,
        _inactivityThreshold = inactivityThreshold;

  /// The port that data is exchanged on
  int get port => _port;

  /// The ip-address of the calling device
  String get ip => _ip;

  /// The path to which files are buffered
  String get bufferPath => _bufferPath;

  /// The amount of seconds it takes for a connection to be considered abandoned
  int get inactivityThreshold => _inactivityThreshold;
}
