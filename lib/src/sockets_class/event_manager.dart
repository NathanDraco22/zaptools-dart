import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/socket_event.dart';
import '../models/zap_data_model.dart';

class EventManager{

  static bool checkZapProtocol(String event,WebSocketChannel socketChannel){
      late final ZapSocketData decoded;
      try {
        decoded = ZapSocketData.fromJsonString(event);
      } catch (e) {
        print("Use a ZapAdapter in your server");
        return false;
      }
      if( decoded.event == "firstConnect"){
        final ZapSocketData firstResponse = ZapSocketData(
            zapId: "--",
            zapAdapter: "Dart Client",
            event: "connected",
            payload: "Conectado a Dart"
          );

        socketChannel.sink.add(firstResponse.toJsonEncoded());

      }
      return true;
  }


  static void dispatchEvents(
    ZapSocketData zapData,
    List<SocketEvent> socketEvents)
    {
    for (var socketEvent in socketEvents) {        
        if( socketEvent.event == zapData.event ){
          socketEvent.callback(zapData.payload);
        }
      }
  }




}