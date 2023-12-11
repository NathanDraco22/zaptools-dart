import 'package:zaptools_client/zaptools_client.dart';

void main() {
  callBackDemo();
// subcribersDemo();
}

void subcribersDemo() async {


  final zSub = ZapSubscriber("ws://127.0.0.1:8000/")..connect();

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

  final zConsumer = ZapConsumer("ws://127.0.0.1:8000/")..connect();

  zConsumer.onConnectionStateChanged(print);

  zConsumer.onConnected((eventData) {
    print("client connected oh yeah!");
    Future.delayed(Duration(seconds: 3))
        .then((value) => zConsumer.disconnect());
  });


  zConsumer.onDisconnected((eventData) {
    print("Client disconnected bye bye");
  });

  // zConsumer.sendEvent("hello", "hello from client");

  zConsumer.onEvent(
    "hello",
    (eventData) {
      print(eventData.name);
      print(eventData.payload);
    },
  );
}
