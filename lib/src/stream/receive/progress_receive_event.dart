import 'package:tcp_link/src/stream/receive/receive_event.dart';

class ProgressReceiveEvent implements ReceiveEvent {
  final int _progress;
  final int _total;

  ProgressReceiveEvent(this._progress, this._total);

  int get total => _total;

  int get progress => _progress;
}
