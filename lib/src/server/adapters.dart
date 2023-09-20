import 'dart:convert';
import 'adapter_interface.dart';

class IOadapter implements ConnectionAdapter {
  @override
  dynamic websocket;

  IOadapter(this.websocket);

  @override
  void sendEvent(String eventName, payload, {Map<String, dynamic> headers = const {}}) {
    final data = {
      "eventName" : eventName,
      "payload" : payload,
      "headers" : headers,
    };
    final jsonData = json.encode(data);
    websocket.add(jsonData);
  }
  
  @override
  void close() {
    websocket.close();
  }
  

}





