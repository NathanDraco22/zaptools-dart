import 'client_event.dart';
import "dart:convert";


class Validators {

  static const _eventKey = "eventName";
  static const _payloadKey = "payload";

  static EventData convertAndValidate( dynamic data) {
    final jsonMap = json.decode(data);
    final eventName = jsonMap[_eventKey];
    final payload = jsonMap[_payloadKey];
    if(eventName == null ) throw Exception("eventName key not found");
    if(payload == null ) throw Exception("payload key not found");
    return EventData(eventName, payload);
  }

}