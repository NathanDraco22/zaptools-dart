import 'dart:io';
import 'package:alfred/alfred.dart';


void main(List<String> args) async {
  
  // final app = Alfred();

  final server = await HttpServer.bind("127.0.0.1", 4040);

  server.listen((event) async{ 
    if (event.uri.path == "/ws") {
      var socket = await WebSocketTransformer.upgrade(event);
      socket.listen(print);
    }

  });

  // app.get("/ws", (req, res) async {
  //   final websocket = await WebSocketTransformer.upgrade(req);
  //   websocket.listen(print);

  // });

  // final server = await app.listen();

  // print("listen on -> ${server.port}");
}







