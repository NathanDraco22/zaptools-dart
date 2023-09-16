import 'dart:async';
import "dart:convert";
import 'package:web_socket_channel/web_socket_channel.dart';

import "client_event.dart";
import "helper.dart";

class ClientConnector {

  static ZapClient connect(Uri uri,{
    Iterable<String>? protocols,
    EventBook? eventBook,
  }){
    final channel = WebSocketChannel.connect(uri, protocols: protocols);
    return ZapClient(
      channel,
      eventBook: eventBook ?? EventBook()
    );
  }

}


class ZapClient{

  final WebSocketChannel webSocketChannel;

  Stream connectionStream;
  WebSocketSink webSocketSink;
  final EventBook _eventBook;
  StreamSubscription? _subscription;

  final StreamController<EventData> _streamController = StreamController<EventData>.broadcast();

  ZapClient(
    this.webSocketChannel,
    {
      required EventBook eventBook
    }
  ): _eventBook = eventBook,
      webSocketSink = webSocketChannel.sink,
      connectionStream = webSocketChannel.stream;

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
    try {webSocketSink.add(jsonString);} 
    catch (e) {print(e);}
  }

  void _invokeEvent(EventData eventData){
    final eventName = eventData.name;
    final event = _eventBook.eventRecords[eventName];
    if (event == null) return;
    event.callback(eventData);
  }

  void start(){
    _invokeEvent(EventData("connected", {}, {}));
    _subscription =  connectionStream.listen((data) {
      final eventData = Validators.convertAndValidate(data);
      _invokeEvent(eventData);
      _streamController.add(eventData);
    },
      cancelOnError: true,
      onDone: (){
        _invokeEvent(EventData("disconnected", {}, {}));
        _subscription?.cancel();
        webSocketSink.close();
      },
    );

  }


  Stream<EventData> subscribeToEvent(String eventName) => 
    _streamController.stream.where((event) => event.name == eventName);
  
  Stream<EventData> subscribeToAllEvent() => _streamController.stream;

  Stream<EventData> subscribeToEvents(List<String> eventNames) {
    return _streamController.stream.where(
      (event) => eventNames.contains(event.name)
    );
  }

  void disconnect() async {
    await _streamController.close();
    await webSocketSink.close();
  } 

}