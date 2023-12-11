abstract class ConnectionAdapter {
  dynamic websocket;

  void sendEvent(String eventName, dynamic payload,
      {Map<String, dynamic> headers});

  void close();
}
