import 'dart:convert';
import 'dart:io';

class LinkSender {
  void test() async {
    final Socket socket = await Socket.connect("192.168.0.60", 4567);

    socket.listen((event) {
      print(utf8.decode(event));
    });

    socket.add(utf8.encode("test"));

    await Future.delayed(const Duration(seconds: 2));

    socket.close();
  }
}
