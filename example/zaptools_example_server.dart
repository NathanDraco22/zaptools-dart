
import 'dart:io';
import 'package:alfred/alfred.dart';
import 'package:zaptools/src/server/adapters.dart';
import 'package:zaptools/src/server/event_processor.dart';
import 'package:zaptools/src/server/websocket_connection.dart';
import 'package:zaptools/src/shared/event_tools.dart';


void main(List<String> args) async {
  
  final app = Alfred();

  final eventRegister = EventRegister();

  eventRegister.onConnected((contexts) { 
    print("client connected !!!!!!!!!!!!");
  });

  eventRegister.onDisconnected((context) {
    print("client disconnected!!!!!");
  });

  eventRegister.onEvent("hola", (context) {
    print(context.eventData.payload);
    context.connection.send("saludo", "teamo");
    Future.delayed(Duration(seconds: 3), () => context.connection.close(),);
   });

  app.get("/ws", (req, res) async {
    final websocket = await WebSocketTransformer.upgrade(req);
    final adapter = IOadapter(websocket);
    final eventCaller = EventCaller(eventRegister.eventBook);
    final wsConn = WebSocketConnection("1", adapter);

    
    final proccesor = EventProcessor(eventCaller, wsConn);
    proccesor.notifyConnected();
    websocket.listen(
      proccesor.interceptRawData,
      onDone: () => proccesor.notifyDisconnected(),
    );
  });

  final server = await app.listen();

  print("listen on -> ${server.port}");
}







