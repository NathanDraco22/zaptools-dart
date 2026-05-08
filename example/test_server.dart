import 'dart:async';

import 'package:zaptools_server/zaptools_server.dart';

void main(List<String> args) async {
  final app = ZapServer();

  app.onConnected((contexts) {
    Timer.periodic(
      Duration(seconds: 1),
      (timer) {
        contexts.connection.send("update", timer.tick);
      },
    );
  });

  final server = await app.start();
  print("listen on -> ${server.port}");
}
