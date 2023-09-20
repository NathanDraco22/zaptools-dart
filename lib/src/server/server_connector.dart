import 'dart:io';

import 'adapters.dart';
import 'event_processor.dart';
import 'websocket_connection.dart';
import 'event_tools_server.dart';


Future<void> plugAndStartWithIO(HttpRequest request, EventRegister eventRegister) async{
    final websocket = await WebSocketTransformer.upgrade(request);
    final adapter = IOadapter(websocket);
    final eventCaller = EventCaller(eventRegister.eventBook);
    final wsConn = WebSocketConnection("1", adapter);
    final proccesor = EventProcessor(eventCaller, wsConn);
    proccesor.notifyConnected();
    websocket.listen(
      proccesor.interceptRawData,
      onDone: () => proccesor.notifyDisconnected(),
    );
}