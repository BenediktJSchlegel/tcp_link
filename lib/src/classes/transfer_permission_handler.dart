import 'package:tcp_link/src/payloads/handshake_payload.dart';

class TransferPermissionHandler {
  final Future<bool> Function(HandshakePayload payload) _onHandshakeReceived;

  TransferPermissionHandler(this._onHandshakeReceived);

  Future<bool> getPermission(HandshakePayload payload) async {
    return _onHandshakeReceived(payload);
  }
}
