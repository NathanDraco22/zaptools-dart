import 'package:zaptools/src/client/connection_state.dart';
import 'package:zaptools/zaptools_client.dart';

void main() {

  Uri uri = Uri.parse("ws://127.0.0.1:3000/ws");
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print("client connected oh yeah!");
   });

  zapClient.onDisconnected((eventData) {
    print("Cliente disconnected bye bye");
  });

  zapClient.sendEvent("hola", "payload");

  zapClient.onEvent("saludo", print);
  
}


void subcribersDemo(){
  Uri uri = Uri.parse("ws://127.0.0.1:3000/ws");
  final zapClient = ClientConnector.attach(uri);

  zapClient.connectionState.listen((event) {
    if (event case ConnectionState.online) {
      print("connected");
      zapClient.sendEvent("hola", "soy el cliente alv~~");
    }
    if (event case ConnectionState.offline) {
      print("disconnected");
      ClientConnector.tryReconnect(zapClient);
    }
  });

  zapClient.subscribeToEvent("saludo").listen(print);
}