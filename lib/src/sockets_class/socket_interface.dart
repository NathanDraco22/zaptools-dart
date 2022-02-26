import '../models/socket_event.dart';

abstract class WebSocketInterface{

  List<SocketEvent> socketEvents = [];

  void onConnected(void Function() callback) {}
  
  void isAboutDisconnected(void Function() callback) {}
  
  void onDisconnected(void Function() onDisconnected) {}

  void disconnect() {}

  void onEvent(String eventName, void Function(dynamic payload) callback) {}

  void onEventStream(String eventName, void Function(dynamic payload) callback){}

  void onAnyEvent(void Function( String event , dynamic payload) callback){}

  void send(String eventName, dynamic payload ) {}

  void deleteEvent( EventRef ref){
    
  }
  
  String? get protocol => throw UnimplementedError();

}