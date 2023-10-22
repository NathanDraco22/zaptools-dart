import 'dart:io';

import 'adapter/adapters.dart';
import 'event_processor.dart';
import 'id_controller.dart';
import 'websocket_connection.dart';
import 'event_tools_server.dart';


Future<void> plugAndStartWithIO(
  HttpRequest request, 
  EventRegister eventRegister,
  {
    ZapIdStrategy idStrategy = const DefaultIDStrategy()
  }
) async{
    final websocket = await WebSocketTransformer.upgrade(request);
    final adapter = IOadapter(websocket);
    final eventCaller = EventCaller(eventRegister.eventBook);
    final id = idStrategy.eval();
    final wsConn = WebSocketConnection(id, adapter);
    final proccesor = EventProcessor(eventCaller, wsConn);
    proccesor.notifyConnected();
    websocket.listen(
      proccesor.interceptRawData,
      onDone: () => proccesor.notifyDisconnected(),
    );
}