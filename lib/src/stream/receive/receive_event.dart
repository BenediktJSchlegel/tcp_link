import 'package:tcp_link/src/stream/receive/done_receive_event.dart';
import 'package:tcp_link/src/stream/receive/failed_receive_event.dart';
import 'package:tcp_link/src/stream/receive/progress_receive_event.dart';

/// Base [ReceiveEvent]. See [DoneReceiveEvent], [FailedReceiveEvent], [ProgressReceiveEvent]
abstract class ReceiveEvent {}
