import 'package:tcp_link/src/classes/completed_data.dart';
import 'package:tcp_link/src/stream/receive/receive_event.dart';

class DoneReceiveEvent implements ReceiveEvent {
  final CompletedData _data;

  DoneReceiveEvent(this._data);

  CompletedData get data => _data;
}
