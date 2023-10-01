import 'package:zaptools/src/server/websocket_connection.dart';
import 'package:zaptools/src/shared/event_tools.dart';

class EventContext {
  EventData eventData;
  WebSocketConnection connection;
  EventContext(this.eventData, this.connection);
}