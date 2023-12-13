import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
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
      title: 'TWO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TWO'),
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
  final LinkSender _sender;

  _MyHomePageState() : _sender = LinkSender();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.ac_unit),
              onPressed: () {
                _sender.sendString("This is a test string");
              },
            ),
            IconButton(
              icon: const Icon(Icons.file_copy),
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: false);

                if (result != null) {
                  File file = result.paths.map((path) => File(path!)).toList()[0];
                  final Uint8List bytes = await file.readAsBytes();

                  _sender.sendFile(file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
