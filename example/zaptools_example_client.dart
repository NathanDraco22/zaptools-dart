import 'package:zaptools_client/zaptools_client.dart';

void main() {
  callBackDemo();
}

void callBackDemo() async {
  final uri = Uri.parse('ws://127.0.0.1:8000/');
  final zConsumer = ZapConsumer(uri)..connect();

  zConsumer.onConnectionStateChanged(print);

  zConsumer.onConnected((eventData) {
    print("client connected oh yeah!");
    Future.delayed(Duration(seconds: 2)).then((value) {
      zConsumer.sendEvent("event1", "hello from client");
      zConsumer.sendEvent("event2", null);
      zConsumer.sendEvent("empty-event", null);
    });
    Future.delayed(Duration(seconds: 10)).then((value) => zConsumer.disconnect());
  });

  zConsumer.onDisconnected((eventData) {
    print("Client disconnected bye bye");
  });

  zConsumer.onConnectionStateChanged(print);

  zConsumer.onAnyEvent((eventData) {
    print(eventData.name);
    print(eventData.payload);
    print(eventData.headers);
  });

  zConsumer.onEvent(
    "hello",
    (eventData) {
      print(eventData.name);
      print(eventData.payload);
    },
  );
}
