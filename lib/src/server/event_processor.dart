import 'dart:convert';
import 'package:zaptools/src/server/event_context.dart';
import 'package:zaptools/src/server/websocket_connection.dart';
import 'package:zaptools/src/shared/event_tools.dart';

class EventProcessor {

  EventCaller eventCaller;
  WebSocketConnection webSocketConnection;

  EventProcessor(this.eventCaller, this.webSocketConnection);

  void notifyConnected(){
    final connectedKey = "connected";
    final eventData = EventData(connectedKey, {}, {});
    final ctx = EventContext(eventData, webSocketConnection);
    eventCaller.triggerEvent(ctx);
  }

  void notifyDisconnected(){
    final connectedKey = "disconnected";
    final eventData = EventData(connectedKey, {}, {});
    final ctx = EventContext(eventData, webSocketConnection);
    eventCaller.triggerEvent(ctx);
  }

  void interceptRawData(dynamic data) {
    final jsonData = json.decode(data);
    interceptJsonData(jsonData);
  }

  void interceptJsonData(Map<String, dynamic> data){
    final eventData = EventData(data["eventName"], data["payload"], data["headers"]);
    final ctx = EventContext(eventData, webSocketConnection);
    eventCaller.triggerEvent(ctx);
  }


}