

abstract class WebSocketInterface{

  void onConnected(void Function() callback) {}
  
  void isAboutDisconnected(void Function() callback) {}
  
  void onDisconnected(void Function() onDisconnected) {}

  void disconnect() {}

  void onEventStream(String eventName, void Function(dynamic payload) callback){}

  void send(String eventName, dynamic payload ) {}
  
  String? get protocol => throw UnimplementedError();

}