import 'package:zaptools_client/zaptools_client.dart';

void main() {
  callBackDemo();
// subcribersDemo();
}

void subcribersDemo() async {
  final uri = Uri.parse('ws://127.0.0.1:8000/');
  final zSub = ZapSubscriber(uri)..connect();

  zSub.connectionState.listen((state) {
    print(state);
    print("mostrando estado");
    // code here
    // No received event after clean
  });

  zSub.subscribeToEvent("hello").listen((eventData) {
    // code here
    // No received event after clean
    print("lo recibimos");
    print(eventData);
  });

  // zSub.sendEvent("hello", "HOLA DESDEL SUBSCRIPTOR");
}

void callBackDemo() async {
  final uri = Uri.parse('ws://127.0.0.1:8000/');
  final zConsumer = ZapConsumer(uri)..connect();

  zConsumer.onConnectionStateChanged(print);

  zConsumer.onConnected((eventData) {
    print("client connected oh yeah!");
    Future.delayed(Duration(seconds: 3))
        .then((value) => zConsumer.disconnect());
  });

  zConsumer.onDisconnected((eventData) {
    print("Client disconnected bye bye");
  });

  zConsumer.onConnectionStateChanged(print);

  zConsumer.onEvent(
    "hello",
    (eventData) {
      print(eventData.name);
      print(eventData.payload);
    },
  );
}
