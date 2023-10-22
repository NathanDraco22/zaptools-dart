import '../shared/event_tools.dart';
import 'websocket_connection.dart';

class EventContext {
  EventData eventData;
  WebSocketConnection connection;
  EventContext(this.eventData, this.connection);
}