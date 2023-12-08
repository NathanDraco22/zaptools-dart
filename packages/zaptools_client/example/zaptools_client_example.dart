import 'package:zaptools_client/zaptools_client.dart';

void main() {

  final zConsumer = ZapConsumer('ws://127.0.0.1:8000/')..connect();

  zConsumer.onConnected((eventData) {
    print('connected!');
  });

  zConsumer.onDisconnected((eventData) {
    print('disconnected!');
  });

  zConsumer.sendEvent('hello', 'hello from client');

  zConsumer.onEvent(
    'bye',
    (eventData) async {
      print(eventData.name);
      print(eventData.payload);
      await Future.delayed(Duration(seconds: 1));
      zConsumer.disconnect;
    },
  );


}
