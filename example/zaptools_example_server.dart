import 'package:zaptools_server/zaptools_server.dart';

void main(List<String> args) async {

  final app = ZapServer();

  app.onConnected((contexts) {
    // when a new client joined
    print("client connected");
  });

  app.onDisconnected((context) {
    // when a client left
    print("client disconnected!");
  });

  app.onEvent("hello", (context) {
    // When the event "hello" is received
    context.connection.send('bye', 'see you!');
   });

  final server = await app.start();
  print("listen on -> ${server.port}");

}







