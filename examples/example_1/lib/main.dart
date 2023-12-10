import 'package:flutter/material.dart';
import 'package:tcp_link/tcp_link.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ONE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ONE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();

    final receiver = LinkReceiver(
      const LinkConfiguration(
          contentPort: 4567,
          handshakePort: 4567,
          ip: "192.168.0.60",
          handshakeTimeout: Duration(seconds: 5)),
    );

    receiver.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: IconButton(
          icon: const Icon(Icons.abc),
          onPressed: () {},
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
