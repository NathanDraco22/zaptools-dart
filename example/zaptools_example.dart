import 'dart:async';

import 'package:zaptools/zaptools.dart';

void main() {
  Uri uri = Uri.parse("ws://127.0.0.1:8000/ws");
  final zapClient = ClientConnector.connect(uri);
    
  zapClient.onDisconnected((eventData) {
    Future.delayed(Duration(seconds: 8), () {
      ClientConnector.tryReconnect(zapClient);
    },);
   });

  zapClient.start();
}


void tryController() async {

  StreamController<int> streamController = StreamController<int>.broadcast();

  final evenNumber = streamController.stream.where((event) => event.isEven);
  final oddNumber = streamController.stream.where((event) => event.isOdd);

  evenNumber.listen(print);
  oddNumber.listen(print);

  for (var i = 0; i < 10; i++) {
    streamController.add(i);
    await Future.delayed(Duration(seconds: 1));
  }

}