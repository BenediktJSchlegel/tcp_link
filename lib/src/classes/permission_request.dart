import 'package:tcp_link/src/payloads/handshake_payload.dart';
import 'package:tcp_link/src/stream/receive/receive_event.dart';

class PermissionRequest {
  final HandshakePayload _payload;
  final Stream<ReceiveEvent> Function() _accept;
  final void Function() _reject;

  PermissionRequest(
    this._payload,
    Stream<ReceiveEvent> Function(HandshakePayload payload) accept,
    void Function(HandshakePayload payload) refuse,
  )   : _accept = (() => accept.call(_payload)),
        _reject = (() => refuse.call(_payload));

  /// Call to reject the [PermissionRequest]
  void Function() get reject => _reject;

  /// Call and listen to the returned [Stream] to accept the [PermissionRequest]
  Stream<ReceiveEvent> Function() get accept => _accept;

  /// The received [HandshakePayload]. Contains information about the [PermissionRequest]
  HandshakePayload get payload => _payload;
}
