import 'package:zaptools/zaptools_server.dart';

void main(List<String> args) async {

  final app = ZapServer();

  app.onConnected((contexts) { 
    print("client connected !!!!!!!!!!!!");
  });

  app.onDisconnected((context) {
    print("client disconnected!!!!!");
  });

  app.onEvent("hola", (context) {
    print(context.eventData.payload);
    context.connection.send("saludo", "teamo");
    Future.delayed(Duration(seconds: 3), () => context.connection.close(),);
   });



  final server = await app.start();

  print("listen on -> ${server.port}");
}







