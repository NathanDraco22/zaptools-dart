import 'package:zaptools/src/server/adapter_interface.dart';

class WebSocketConnection {

  String id;
  ConnectionAdapter connectionAdapter;

  WebSocketConnection(this.id, this.connectionAdapter);

  void send(String eventName, dynamic payload, Map<String,dynamic>? header){
    connectionAdapter.sendEvent(eventName, payload, {});

  }

  void close(){
    connectionAdapter.close();
  }

}

