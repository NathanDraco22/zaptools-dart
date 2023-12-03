import 'helper.dart';

class EventData {
  Map<String, dynamic> headers;
  String name;
  dynamic payload;
  EventData(this.name, this.payload, this.headers);
  EventData.fromEventName( String eventName)
    : name = eventName,
      payload = {},
      headers = {};
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

class StreamEventTranformer {
  static Stream<EventData> serialize(Stream<dynamic> stream) =>
      stream.map((data) => Validators.convertAndValidate(data));
}

class EventInvoker {
  final EventBook eventBook;
  EventInvoker(this.eventBook);

  bool invoke(EventData eventData) {
    final eventName = eventData.name;
    final event = eventBook.eventRecords[eventName];
    if (event == null) return false;
    event.callback(eventData);
    return true;
  }
}
