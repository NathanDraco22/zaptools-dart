import 'package:zaptools/src/server/adapter/adapter_interface.dart';
import 'package:zaptools/src/server/adapter/adapters.dart';

class WebSocketConnection {

  String id;
  ConnectionAdapter connectionAdapter;

  WebSocketConnection(this.id, this.connectionAdapter);

  WebSocketConnection.io(this.id, dynamic websocket):
    connectionAdapter = IOadapter(websocket);

  void send(String eventName, dynamic payload, {Map<String,dynamic>? headers}){
    connectionAdapter.sendEvent(eventName, payload, headers: headers ?? {});
  }

  void close(){
    connectionAdapter.close();
  }

}

