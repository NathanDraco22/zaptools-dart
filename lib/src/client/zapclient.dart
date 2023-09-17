import 'dart:async';
import "dart:convert";
import 'package:web_socket_channel/web_socket_channel.dart';

import "client_event.dart";
import "helper.dart";
import "websocket_session.dart";

class ZapClient{

  WebSocketSession _webSocketSession;

  Stream _connectionStream;
  WebSocketSink _webSocketSink;
  final EventBook _eventBook;
  StreamSubscription? _subscription;

  final StreamController<EventData> _streamController = StreamController<EventData>.broadcast();

  ZapClient(
    WebSocketSession webSocketSession,
    {
      required EventBook eventBook
    }
  ): _eventBook = eventBook,
      _webSocketSink = webSocketSession.channel.sink,
      _connectionStream = webSocketSession.channel.stream,
      _webSocketSession = webSocketSession;


  Uri get uri => _webSocketSession.uri;

  void onConnected(EventCallback callback ) {
    _eventBook.saveEvent(Event("connected", callback));
  }

  void onDisconnected(EventCallback callback ) {
    _eventBook.saveEvent(Event("disconnected", callback));
  }


  void onEvent(String eventName, EventCallback callback ) {
    _eventBook.saveEvent(Event(eventName, callback));
  }

  void sendEvent(String eventName, dynamic payload, Map<String,dynamic>? headers){
    final data = {
      "headers" : headers ?? {},
      "eventName" : eventName,
      "payload" : payload
    };
    final jsonString = json.encode(data);
    try {_webSocketSink.add(jsonString);} 
    catch (e) {print(e);}
  }

  void _invokeEvent(EventData eventData){
    final eventName = eventData.name;
    final event = _eventBook.eventRecords[eventName];
    if (event == null) return;
    event.callback(eventData);
  }

  void start()async {
    await _webSocketSession.channel.ready;
    _invokeEvent(EventData("connected", {}, {}));
    _subscription =  _connectionStream.listen((data) {
      final eventData = Validators.convertAndValidate(data);
      _invokeEvent(eventData);
      _streamController.add(eventData);
    },
      cancelOnError: true,
      onDone: (){
        _invokeEvent(EventData("disconnected", {}, {}));
        _subscription?.cancel();
        _webSocketSink.close();
      }
    );
  }

  void updateSession(WebSocketSession webSocketSession){
    _webSocketSession = webSocketSession;
    _webSocketSink = webSocketSession.channel.sink;
    _connectionStream = webSocketSession.channel.stream;
  }


  Stream<EventData> subscribeToEvent(String eventName) => 
    _streamController.stream.where((event) => event.name == eventName);
  
  Stream<EventData> subscribeToAllEvent() => _streamController.stream;

  Stream<EventData> subscribeToEvents(List<String> eventNames) {
    return _streamController.stream.where(
      (event) => eventNames.contains(event.name)
    );
  }

  Future<void> disconnect() async {
    await _webSocketSink.close();
  } 

  Future<void> clean() async {
    await _streamController.close();
    await _webSocketSink.close();
  } 

}