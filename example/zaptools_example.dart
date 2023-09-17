import 'dart:async';

import 'package:zaptools/zaptools.dart';

void main() {
  Uri uri = Uri.parse("ws://127.0.0.1:8000/ws");
  final zapClient = ClientConnector.connect(uri);

  final sub = zapClient.subscribeToAllEvent();

  sub.listen(print);

  zapClient.onDisconnected((eventData) {
    Future.delayed(Duration(seconds: 8), () {
      ClientConnector.tryReconnect(zapClient);
    },);
   });

  zapClient.start();
}
