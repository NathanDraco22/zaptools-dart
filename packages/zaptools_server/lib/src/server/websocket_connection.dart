

import 'adapter/adapter_interface.dart';
import 'adapter/adapters.dart';

class WebSocketConnection {

  final String id;
  final ConnectionAdapter _connectionAdapter;

  WebSocketConnection(this.id, ConnectionAdapter connectionAdapter):
    _connectionAdapter = connectionAdapter;

  WebSocketConnection.io(this.id, dynamic websocket):
    _connectionAdapter = IOadapter(websocket);

  void send(String eventName, dynamic payload, {Map<String,dynamic>? headers}){
    _connectionAdapter.sendEvent(eventName, payload, headers: headers ?? {});
  }

  void close(){
    _connectionAdapter.close();
  }

}

