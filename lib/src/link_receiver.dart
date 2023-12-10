import 'package:tcp_link/src/configuration/link_configuration.dart';
import 'package:tcp_link/src/connection/handshake_receiver.dart';
import 'package:tcp_link/src/enums/handshake_response_status.dart';
import 'package:tcp_link/src/logging/link_logger.dart';
import 'package:tcp_link/src/logging/print_logger.dart';
import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/payloads/responses/handshake_response_payload.dart';
import 'package:tcp_link/src/serialization/payload_serializer.dart';

class LinkReceiver {
  final LinkConfiguration _configuration;
  final PayloadSerializer _serializer;
  final LinkLogger _logger;

  HandshakeReceiver? _handshakeReceiver;

  // TODO: inject logger
  LinkReceiver(this._configuration)
      : _serializer = PayloadSerializer(),
        _logger = PrintLogger();

  void start() {
    _startHandshake();
  }

  void stop() {
    _handshakeReceiver?.close();
  }

  void _startHandshake() {
    _handshakeReceiver = HandshakeReceiver(
      _configuration.ip,
      _configuration.handshakePort,
      _onHandshakeReceived,
      _serializer,
      _logger,
    );

    _handshakeReceiver!.bind();
  }

  HandshakeResponsePayload _onHandshakeReceived(HandshakePayload payload) {
    // TODO: change -> temporarily just allow all handshakes
    return HandshakeResponsePayload(
      _configuration.ip,
      HandshakeResponseStatus.ready,
      DateTime.now(),
      DateTime.now().add(const Duration(seconds: 5)),
    );
  }
}
