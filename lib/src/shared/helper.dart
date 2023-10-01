import 'event_tools.dart';
import "dart:convert";


class Validators {

  static const _eventKey = "eventName";
  static const _payloadKey = "payload";
  static const _headersKey = "headers";

  static EventData convertAndValidate( dynamic data) {
    final jsonMap = json.decode(data);
    final eventName = jsonMap[_eventKey];
    final payload = jsonMap[_payloadKey];
    final headers = jsonMap[_headersKey];
    if(eventName == null ) throw Exception("eventName key not found");
    if(payload == null ) throw Exception("payload key not found");
    if(headers == null ) throw Exception("headers key not found");
    return EventData(eventName, payload, headers);
  }

}