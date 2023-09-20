import 'package:zaptools/zaptools_client.dart';

void main() {
  Uri uri = Uri.parse("ws://127.0.0.1:3000/ws");
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print("client connected");
    zapClient.sendEvent("hola", "esto es un payload", {});
  });

  zapClient.onEvent("saludo", (eventData) { 
    print(eventData.payload);
  });

  zapClient.onDisconnected((eventData) {
    print("connection lost!");
  });

  zapClient.start();
}
