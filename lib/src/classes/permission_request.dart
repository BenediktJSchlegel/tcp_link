import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/stream/receive/receive_event.dart';

class PermissionRequest {
  final HandshakePayload _payload;
  final Stream<ReceiveEvent> Function() _accept;
  final void Function() _refuse;

  PermissionRequest(
    this._payload,
    Stream<ReceiveEvent> Function(HandshakePayload payload) accept,
    void Function(HandshakePayload payload) refuse,
  )   : _accept = (() => accept.call(_payload)),
        _refuse = (() => refuse.call(_payload));

  void Function() get reject => _refuse;

  Stream<ReceiveEvent> Function() get accept => _accept;

  HandshakePayload get payload => _payload;
}
