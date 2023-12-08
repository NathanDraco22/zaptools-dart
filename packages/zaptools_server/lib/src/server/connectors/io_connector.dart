import 'dart:async';
import 'dart:io';
import 'package:zaptools_server/src/server/id_controller.dart';
import '../adapter/adapters.dart';
import '../event_processor.dart';
import '../event_tools_server.dart';
import '../websocket_connection.dart';

class IOConnector {

  IOConnector(
    this.request, 
    this.eventRegister, 
    {this.idStrategy = const DefaultIDStrategy()}
  );

  final HttpRequest request;
  final EventRegister eventRegister;
  final ZapIdStrategy idStrategy;

  StreamSubscription? subscription;

  void start()async{
    final websocket = await WebSocketTransformer.upgrade(request);
    final adapter = IOadapter(websocket);
    final eventCaller = EventCaller(eventRegister.eventBook);
    final id = idStrategy.eval();
    final wsConn = WebSocketConnection(id, adapter);
    final proccesor = EventProcessor(eventCaller, wsConn);
    proccesor.notifyConnected();
    subscription =  websocket.listen(
      proccesor.interceptRawData,
      onDone: () {
        subscription?.cancel();
        proccesor.notifyDisconnected();
      },
    );
  }

  void close(){
    subscription?.cancel();
  }

}

