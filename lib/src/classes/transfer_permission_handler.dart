import 'package:tcp_link/src/payloads/handshake_payload.dart';

class TransferPermissionHandler {
  final bool Function(HandshakePayload payload) _onHandshakeReceived;

  TransferPermissionHandler(this._onHandshakeReceived);

  bool getPermission(HandshakePayload payload) {
    return _onHandshakeReceived(payload);
  }
}
