import 'package:tcp_link/src/stream/receive/receive_event.dart';

/// Signals that the receive-process is ongoing
class ProgressReceiveEvent implements ReceiveEvent {
  final int _progress;
  final int _total;

  ProgressReceiveEvent(this._progress, this._total);

  /// Total amount of bytes that is expected to be received
  int get total => _total;

  /// The Amount of Bytes that have been received
  int get progress => _progress;
}
