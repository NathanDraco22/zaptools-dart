import 'dart:async';
import 'dart:io';

import '../adapter/adapters.dart';
import '../tools/event_processor.dart';
import '../tools/id_controller.dart';
import '../tools/event_register.dart';
import '../tools/event_tools.dart';
import '../websocket_connection.dart';


@Deprecated("will removed in 0.3.0")
Future<void> plugAndStartWithIO(
    HttpRequest request, EventRegister eventRegister,
    {ZapIdStrategy idStrategy = const DefaultIDStrategy()}) async {
  final websocket = await WebSocketTransformer.upgrade(request);
  final adapter = IOadapter(websocket);
  final eventCaller = EventCaller(eventRegister.eventBook);
  final id = idStrategy.eval();
  final wsConn = WebSocketConnection(id, adapter);
  final proccesor = EventProcessor(eventCaller, wsConn);
  proccesor.notifyConnected();
  StreamSubscription? subscription;
  subscription =  websocket.listen(
    proccesor.interceptRawData,
    onDone: () {
      subscription?.cancel();
      proccesor.notifyDisconnected();
    },
  );
}
