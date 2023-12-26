import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'received_list_item.dart';
import 'utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';
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
  final DateFormat _formatter = DateFormat('dd.MM.yyyy hh:mm');

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<ReceivedListItem> _receivedData = [];

  static const _targetKey = "target_key";
  static const _ipKey = "ip_key";

  double _currentReceiveProgress = 0.0;
  bool _progressOngoing = false;

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

  Future<void> _onHandshakeReceived(PermissionRequest request) async {
    if (request.payload.type != ContentPayloadTypes.file) {
      _acceptTransfer(request.accept.call());
      return;
    }

    Utils(context).showHandshakeDialog(request, _acceptTransfer);
  }

  void _acceptTransfer(Stream<ReceiveEvent> stream) {
    if (!_progressOngoing) {
      _progressOngoing = true;
      _showProgressDialog();
    }

    stream.listen((event) {
      print(event.runtimeType);

      switch (event.runtimeType) {
        case ProgressReceiveEvent:
          final progressEvent = (event as ProgressReceiveEvent);

          _currentReceiveProgress = progressEvent.progress / progressEvent.total;

          try {
            _dialogSetState?.call(() {});
          } on Object catch (o) {
            print(o);
          }
          break;
        case FailedReceiveEvent:
          _currentReceiveProgress = 0.0;
          _progressOngoing = false;
          _dialogSetState = null;

          if (_isShowingAlert()) {
            Navigator.of(context).pop();
          }

          Utils(context).showErrorDialog();
          break;
        case DoneReceiveEvent:
          _handleReceivedData((event as DoneReceiveEvent).data);

          _currentReceiveProgress = 0.0;
          _progressOngoing = false;
          _dialogSetState = null;

          if (_isShowingAlert()) {
            Navigator.of(context).pop();
          }
          break;
      }
    });
  }

  StateSetter? _dialogSetState;

  bool _isShowingAlert() {
    return !(ModalRoute.of(context)?.isCurrent ?? false);
  }

  void _showProgressDialog() {
    AlertDialog dialog = AlertDialog(
      icon: const Icon(Icons.info_rounded),
      title: const Text("Receiving Data . . ."),
      content: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        _dialogSetState = setState;

        return SizedBox(
          height: 25,
          width: 100,
          child: LinearProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            value: _currentReceiveProgress,
          ),
        );
      }),
    );

    showDialog(context: context, builder: (_) => dialog);
  }

  void _handleReceivedData(CompletedData data) {
    switch (data.runtimeType) {
      case CompletedFileData:
        final file = data as CompletedFileData;
        _onFileReceived(file.filename, file.tempFilePath);
        break;
      case CompletedStringData:
        _onStringReceived((data as CompletedStringData).data);
        break;
      case CompletedJsonData:
        _onJsonReceived((data as CompletedJsonData).json);
        break;
    }
  }

  void _onStringReceived(String data) {
    setState(() {
      _receivedData.add(ReceivedListItem("${_formatter.format(DateTime.now())} - String:", data));
    });
  }

  void _onJsonReceived(Map<String, dynamic> json) {
    setState(() {
      _receivedData
          .add(ReceivedListItem("${_formatter.format(DateTime.now())} - Json:", jsonEncode(json)));
    });
  }

  void _onFileReceived(String filename, String tempPath) async {
    final x = await File(tempPath).exists();

    setState(() {
      _receivedData.add(
          ReceivedListItem("${_formatter.format(DateTime.now())} - File: $filename", tempPath));
    });
  }

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
        onTransferPermissionRequestedCallback: (request) => _onHandshakeReceived(request),
        loggingConfiguration: LoggingConfiguration.print(LoggingVerbosity.info),
        config: LinkConfiguration(ip: _ownIp!, port: 4567, bufferPath: await _getBufferPath()),
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

  Future<String> _getBufferPath() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download/buffer";
    } else if (Platform.isWindows) {
      return "link-buffer\\buffer";
    }

    return (await getTemporaryDirectory()).path;
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

      _setPageLoading(true);

      DataSendResult sendResult = await _sender!.sendFile(SenderTarget(_targetIp!, 4567), file);

      _handleSendResult(sendResult);
    }
  }

  void _setPageLoading(bool value) {
    if (value) {
      Utils(context).startLoading();
    } else {
      Utils(context).stopLoading();
    }
  }

  void _onSendPressed() async {
    _setPageLoading(true);

    DataSendResult sendResult =
        await _sender!.sendString(SenderTarget(_targetIp!, 4567), _contentController.text);

    _handleSendResult(sendResult);

    if (sendResult.successful) {
      _contentController.text = "";
    }
  }

  void _handleSendResult(DataSendResult result) {
    _setPageLoading(false);

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
                        Flexible(
                          child: Text(
                            _receivedData[index].title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(_receivedData[index].content,
                              style: const TextStyle(fontSize: 16), softWrap: true),
                        ),
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
