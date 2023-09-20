
import 'event_context.dart';

typedef ContextCallBack = void Function(EventContext context);

class ServerEvent {
  String name;
  ContextCallBack callback;
  ServerEvent(this.name, this.callback);
}

class ServerEventBook {
  final Map<String, ServerEvent> eventRecords = {};

  ServerEventBook();

  void saveEvent(ServerEvent event) => eventRecords[event.name] = event;

  ServerEvent? getEvent(String eventName) => eventRecords[eventName];

}

class EventRegister {
  ServerEventBook eventBook;

  EventRegister([ServerEventBook? eventBook])
  : eventBook = eventBook ?? ServerEventBook();

  void onConnected(ContextCallBack callBack) {
    eventBook.saveEvent(ServerEvent("connected", callBack));
  }

  void onDisconnected(ContextCallBack callBack) {
    eventBook.saveEvent(ServerEvent("disconnected", callBack));
  }

  void onEvent(String eventName ,ContextCallBack callback){
    eventBook.saveEvent(ServerEvent(eventName, callback));
  }

}

class EventCaller {
  ServerEventBook eventBook;

  EventCaller(this.eventBook);

  void triggerEvent(EventContext context) {
    final event = eventBook.getEvent(context.eventData.name);
    if(event == null) return;
    event.callback(context);
  }

}