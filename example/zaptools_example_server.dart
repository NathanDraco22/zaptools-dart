import 'package:alfred/alfred.dart';
import 'package:zaptools/zaptools_server.dart';


void main(List<String> args) async {
  
  final app = Alfred();

  final eventRegister = EventRegister();

  eventRegister.onConnected((contexts) { 
    print("client connected !!!!!!!!!!!!");
  });

  eventRegister.onDisconnected((context) {
    print("client disconnected!!!!!");
  });

  eventRegister.onEvent("hola", (context) {
    print(context.eventData.payload);
    context.connection.send("saludo", "teamo");
    Future.delayed(Duration(seconds: 3), () => context.connection.close(),);
   });

  app.get("/ws", (req, res) async {
    plugAndStartWithIO(req, eventRegister);
  });

  final server = await app.listen();

  print("listen on -> ${server.port}");
}







