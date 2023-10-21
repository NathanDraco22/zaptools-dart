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

  app.onEvent("hola", (context) {
    // When a event the event "myEvent" is received
    context.connection.send("saludo", "te estoy saludando desde el servidor");
   });

  final server = await app.start();
  print("listen on -> ${server.port}");

}







