
class EventData {
  Map<String, dynamic> headers;
  String name;
  dynamic payload;
  EventData(this.name, this.payload, this.headers);
}


typedef EventCallback = void Function(EventData eventData);

class Event {
  String name;
  EventCallback callback;
  Event(this.name, this.callback);
}


class EventBook {
  final Map<String, Event> eventRecords = {};

  EventBook();

  void saveEvent(Event event) => eventRecords[event.name] = event;

  Event? getEvent(String eventName) => eventRecords[eventName];

}

class EventRegister {
  EventBook eventBook;

  EventRegister(this.eventBook);

  void onEvent(String eventName ,EventCallback callback){
    eventBook.saveEvent(Event(eventName, callback));
  }

}

class EventCaller {
  EventBook eventBook;

  EventCaller(this.eventBook);

}