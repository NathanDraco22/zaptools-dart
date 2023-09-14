class EventData {
  String eventName;
  dynamic payload;
  EventData(this.eventName, this.payload);
}


typedef EventCallback = void Function(EventData eventData);

class Event {
  String name;
  EventCallback callback;
  Event(this.name, this.callback);
}


class ClientEventManager {
  final Map<String, Event> eventBook = {};

  ClientEventManager();

  void saveEvent(Event event) => eventBook[event.name] = event;

  Event? getEvent(String eventName) => eventBook[eventName];

}