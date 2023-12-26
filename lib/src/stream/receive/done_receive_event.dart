import 'package:tcp_link/src/classes/completed_data.dart';
import 'package:tcp_link/src/stream/receive/receive_event.dart';

/// Signals that the receive-process has completed successfully
class DoneReceiveEvent implements ReceiveEvent {
  final CompletedData _data;

  DoneReceiveEvent(this._data);

  /// The data that was received
  CompletedData get data => _data;
}
