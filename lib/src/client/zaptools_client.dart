import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import "dart:convert";

import "client_event.dart";
import "helper.dart";

class ClientConnector {

  static ZapClient connect(Uri uri,{
    Iterable<String>? protocols,
    ClientEventManager? clientEventManager,
  }){
    final channel = WebSocketChannel.connect(uri, protocols: protocols);
    return ZapClient(
      channel.stream, 
      channel.sink,
      clientEventManager: clientEventManager ?? ClientEventManager()
    );
  }

}


class ZapClient{

  Stream connectionStream;
  WebSocketSink webSocketSink;
  final ClientEventManager _clientEventManager;
  StreamSubscription? _subscription;

  final StreamController<EventData> _streamController = StreamController<EventData>.broadcast();

  ZapClient(
    this.connectionStream,
    this.webSocketSink,
    {
      required ClientEventManager clientEventManager
    }
  ): _clientEventManager = clientEventManager {
    _startEventStream();
   }

  void onEvent(String eventName, EventCallback callback ) {
    _clientEventManager.saveEvent(Event(eventName, callback));
  }

  void sendEvent(String eventName, dynamic payload, Map<String,dynamic>? headers){
    final data = {
      if(headers != null) "headers" : headers,
      "eventName" : eventName,
      "payload" : payload
    };
    final jsonString = json.encode(data);
    try {webSocketSink.add(jsonString);} 
    catch (e) {print(e);}
  }

  void _invokeEvent(EventData eventData){
    final eventName = eventData.eventName;
    final event = _clientEventManager.eventBook[eventName];
    if (event == null) return;
    event.callback(eventData);
  }

  void _startEventStream(){
    _subscription =  connectionStream.listen((data) { 
      final eventData = Validators.convertAndValidate(data);
      _invokeEvent(eventData);
      _streamController.add(eventData);
    },
      cancelOnError: true,
      onDone: (){
        _subscription?.cancel();
        webSocketSink.close();
      },
    );

  }


  Stream<EventData> subscribeToEvent(String eventName) => 
    _streamController.stream.where((event) => event.eventName == eventName);
  
  Stream<EventData> subscribeToAllEvent() => _streamController.stream;

  Stream<EventData> subscribeToEvents(List<String> eventNames) {
    return _streamController.stream.where(
      (event) => eventNames.contains(event.eventName)
    );
  }

  void disconnect() async {
    await _streamController.close();
    await webSocketSink.close();
  } 

}