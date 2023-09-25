import 'package:test/test.dart';
import 'package:zaptools/src/shared/event_tools.dart';
import 'package:zaptools/src/shared/helper.dart';

import 'zaptool_server_data.mock.dart';

void main() {
  
  group("Test Validators ->", (){

    test("convertAndValidate", (){
      List<EventData> eventsData = [];
      for (var data in mockData) {
        final result = Validators.convertAndValidate(data);
        eventsData.add(result);
      }
      expect(eventsData.first.name, "event1");
      expect(eventsData.first.payload, "payload1");
      expect(eventsData.first.headers["myHeader"], "value");
    });

    test("eventBook - saveEvent", () {
      final eventBook = EventBook();
      final event = Event("event1", (eventData) => print("Hello!") );
      expect(eventBook.eventRecords.length, 0);
      eventBook.saveEvent(event);
      expect(eventBook.eventRecords.length, 1);
    });

    test("eventBook - getEvent", () {
      final eventBook = EventBook();
      final event = Event("event1", (eventData) => print("Hello!") );
      expect(eventBook.eventRecords.length, 0);
      eventBook.saveEvent(event);
      final res = eventBook.getEvent("event1");
      final res2 = eventBook.getEvent("event0");
      expect(res?.name, "event1");
      expect(res2, null);
    });

    test("EventInvoker", () {
      
    });

  });



}

