import 'package:flutter/material.dart';
import 'package:tcp_link/tcp_link.dart';

class Utils {
  late BuildContext context;

  Utils(this.context);

  Future<void> startLoading() async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.black.withAlpha(70),
          children: const <Widget>[
            Center(
              child: CircularProgressIndicator(),
            )
          ],
        );
      },
    );
  }

  Future<void> stopLoading() async {
    Navigator.of(context).pop();
  }

  void showErrorDialog() {
    final AlertDialog dialog = AlertDialog(
      title: const Text("Failed Receiving Data"),
      icon: const Icon(Icons.error),
      actions: [
        TextButton(
          child: const Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  void showHandshakeDialog(
      PermissionRequest request, void Function(Stream<ReceiveEvent> stream) accept) {
    final AlertDialog dialog = AlertDialog(
      content: Text(
          "Allow transfer from ${request.payload.senderIp}? Name: ${request.payload.filename} - Length: ${request.payload.contentLength}"),
      icon: const Icon(Icons.file_copy),
      actions: [
        TextButton(
          child: const Text("No"),
          onPressed: () {
            Navigator.pop(context);

            request.reject();
          },
        ),
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            Navigator.pop(context);

            accept(request.accept.call());
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);
  }
}
