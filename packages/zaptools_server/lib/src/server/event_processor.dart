import '../shared/event_tools.dart';
import '../shared/helper.dart';
import 'event_context.dart';
import 'websocket_connection.dart';
import 'event_tools_server.dart';

class EventProcessor {
  EventCaller eventCaller;
  WebSocketConnection webSocketConnection;

  EventProcessor(this.eventCaller, this.webSocketConnection);

  void notifyConnected() {
    final connectedKey = "connected";
    final eventData = EventData(connectedKey, {}, {});
    final ctx = EventContext(eventData, webSocketConnection);
    eventCaller.triggerEvent(ctx);
  }

  void notifyDisconnected() {
    final connectedKey = "disconnected";
    final eventData = EventData(connectedKey, {}, {});
    final ctx = EventContext(eventData, webSocketConnection);
    eventCaller.triggerEvent(ctx);
  }

  void interceptRawData(dynamic data) {
    final eventData = Validators.convertAndValidate(data);
    interceptEventData(eventData);
  }

  void interceptEventData(EventData eventData) {
    final ctx = EventContext(eventData, webSocketConnection);
    eventCaller.triggerEvent(ctx);
  }
}
