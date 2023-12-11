import '../../shared/event_tools.dart';
import '../websocket_connection.dart';

class EventContext {
  EventContext( this.eventData, this.connection):
  eventName = eventData.name,
  payload = eventData.payload,
  headers = eventData.headers;

  EventData eventData;
  WebSocketConnection connection;
  String eventName;
  dynamic payload;
  Map<String, dynamic> headers;
}
