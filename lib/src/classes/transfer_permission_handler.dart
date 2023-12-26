import 'package:tcp_link/src/classes/permission_request.dart';

class TransferPermissionHandler {
  final void Function(PermissionRequest request) _onHandshakeReceived;

  TransferPermissionHandler(this._onHandshakeReceived);

  void getPermission(PermissionRequest request) {
    return _onHandshakeReceived(request);
  }
}
