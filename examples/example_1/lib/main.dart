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
      onTransferPermissionRequestedCallback: (payload) => true,
      loggingConfiguration: LoggingConfiguration.print(LoggingVerbosity.info),
      config: const LinkConfiguration(ip: "192.168.0.60", port: 4567),
      onStringReceived: (data) {
        print("STRING WAS RECEIVED!!! $data");
      },
      onJsonReceived: (json) {
        print("JSON WAS RECEIVED!!!");
      },
      onFileReceived: (ReceivedFile file) {
        print("FILE WAS RECEIVED!!! ${file.filename}");
      },
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
      ),
    );
  }
}
