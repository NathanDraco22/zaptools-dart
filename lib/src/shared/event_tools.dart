
import 'package:zaptools/src/server/event_context.dart';

class EventData {
  Map<String, dynamic> headers;
  String name;
  dynamic payload;
  EventData(this.name, this.payload, this.headers);
}


typedef EventCallback = void Function(EventData eventData);
typedef ContextCallBack = void Function(EventContext context);

class Event {
  String name;
  EventCallback callback;
  Event(this.name, this.callback);
}

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

class EventBook {
  final Map<String, Event> eventRecords = {};

  EventBook();

  void saveEvent(Event event) => eventRecords[event.name] = event;

  Event? getEvent(String eventName) => eventRecords[eventName];

}

class EventRegister {
  ServerEventBook eventBook;

  EventRegister(this.eventBook);

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