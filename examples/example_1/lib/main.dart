import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

import 'package:example_1/received_list_item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tcp_link/tcp_link.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCP-Link Example',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'TCP-Link Example'),
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
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<ReceivedListItem> _receivedData = [];

  static const _targetKey = "target_key";
  static const _ipKey = "ip_key";

  String? _ownIp;
  LinkReceiver? _receiver;
  bool _isListening = false;
  LinkSender? _sender;
  String? _targetIp;

  @override
  void initState() {
    super.initState();

    getInitialTarget();

    if (!Platform.isAndroid) {
      getInitialOwnIp();
    }
  }

  void getInitialOwnIp() async {
    _ipController.text = (await _prefs).getString(_ipKey) ?? "";
    _ownIp = _ipController.text;
  }

  void getInitialTarget() async {
    _targetController.text = (await _prefs).getString(_targetKey) ?? "";
    _targetIp = _targetController.text;

    setState(() {});
  }

  Future<bool> _onHandshakeReceived(HandshakePayload payload) async {
    if (payload.type != ContentPayloadTypes.file) {
      return true;
    }

    Completer<bool> completer = Completer();

    final AlertDialog dialog = AlertDialog(
      content: Text(
          "Allow transfer from ${payload.senderIp}? Name: ${payload.filename} - Length: ${payload.contentLength}"),
      icon: const Icon(Icons.file_copy),
      actions: [
        TextButton(
          child: const Text("No"),
          onPressed: () {
            completer.complete(false);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            completer.complete(true);
            Navigator.pop(context);
          },
        ),
      ],
    );

    showDialog(context: context, builder: (_) => dialog);

    return await completer.future;
  }

  final DateFormat _formatter = DateFormat('dd.MM.yyyy hh:mm');

  void _startListening() async {
    if (Platform.isAndroid) {
      _ownIp = await NetworkInfo().getWifiIP();
    } else {
      (await _prefs).setString(_ipKey, _ipController.text);
      _ownIp = _ipController.text;
    }

    _ipController.text = _ownIp ?? "FAILED";

    if (_ownIp != null) {
      _receiver = LinkReceiver(
        onTransferPermissionRequestedCallback: (payload) => _onHandshakeReceived(payload),
        loggingConfiguration: LoggingConfiguration.print(LoggingVerbosity.info),
        config: LinkConfiguration(ip: _ownIp!, port: 4567),
        onStringReceived: (String data) {
          setState(() {
            _receivedData
                .add(ReceivedListItem("${_formatter.format(DateTime.now())} - String:", data));
          });
        },
        onJsonReceived: (Map<String, dynamic> json) {
          setState(() {
            _receivedData.add(
                ReceivedListItem("${_formatter.format(DateTime.now())} - Json:", jsonEncode(json)));
          });
        },
        onFileReceived: (ReceivedFile file) {
          setState(() {
            _receivedData.add(ReceivedListItem("${_formatter.format(DateTime.now())} - File:",
                "${file.filename} - ${file.bytes.length}"));
          });
        },
      );

      _sender = LinkSender(
        loggingConfiguration: LoggingConfiguration.print(LoggingVerbosity.info),
        configuration: SenderConfiguration(_ownIp!, 10),
      );

      _receiver!.start();

      _isListening = true;
    } else {
      _isListening = false;
    }
    setState(() {});
  }

  void _stopListening() {
    _receiver?.stop();

    setState(() {
      _isListening = false;
    });
  }

  void _onFilePressed() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null && _targetIp != null) {
      File file = result.paths.map((path) => File(path!)).toList()[0];

      DataSendResult sendResult = await _sender!.sendFile(SenderTarget(_targetIp!, 4567), file);

      _handleSendResult(sendResult);
    }
  }

  void _onSendPressed() async {
    DataSendResult sendResult =
        await _sender!.sendString(SenderTarget(_targetIp!, 4567), _contentController.text);

    _handleSendResult(sendResult);

    if (sendResult.successful) {
      _contentController.text = "";
    }
  }

  void _handleSendResult(DataSendResult result) {
    if (!result.successful) {
      final AlertDialog dialog = AlertDialog(
        title: const Text("Failed Sending Data"),
        content: Text(result.error?.toString() ?? ""),
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
  }

  void _onSavePressed() async {
    (await _prefs).setString(_targetKey, _targetController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _receivedData.length,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                    border: BorderDirectional(bottom: BorderSide(width: 1.0, color: Colors.black))),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(_receivedData[index].title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(_receivedData[index].content, style: const TextStyle(fontSize: 16)),
                      ],
                    )
                  ],
                ),
              );
            },
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Flex(
              direction: Axis.vertical,
              children: [
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 70,
                            child: TextField(
                              controller: _contentController,
                              onSubmitted: (_) => _onSendPressed(),
                              decoration: const InputDecoration(labelText: "Content"),
                            )),
                        Expanded(
                            flex: 15,
                            child: IconButton(
                              onPressed: _onFilePressed,
                              icon: const Icon(
                                Icons.file_copy,
                                size: 32,
                              ),
                            )),
                        Expanded(
                            flex: 15,
                            child: IconButton(
                              onPressed: _onSendPressed,
                              icon: const Icon(
                                Icons.send,
                                size: 32,
                              ),
                            )),
                      ],
                    )),
                Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 80,
                            child: TextField(
                              controller: _targetController,
                              decoration: const InputDecoration(labelText: "Target"),
                            )),
                        Expanded(
                          flex: 20,
                          child: IconButton(
                            onPressed: _onSavePressed,
                            icon: const Icon(
                              Icons.save,
                              size: 32,
                            ),
                          ),
                        )
                      ],
                    )),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 80,
                        child: TextField(
                          enabled: !Platform.isAndroid,
                          controller: _ipController,
                        ),
                      ),
                      Expanded(
                          flex: 20,
                          child: IconButton(
                            icon: _isListening
                                ? const Icon(
                                    Icons.electric_bolt_outlined,
                                    size: 32,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.bolt,
                                    size: 32,
                                    color: Colors.green,
                                  ),
                            onPressed: _isListening ? _stopListening : _startListening,
                          ))
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
