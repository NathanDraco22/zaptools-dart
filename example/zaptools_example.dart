import 'package:zaptools/src/client/connection_state.dart';
import 'package:zaptools/zaptools_client.dart';

void main() {

callBackDemo();
  
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
      print("disconnected   bye bye");
    }
  });

  zapClient.subscribeToEvent("saludo").listen(print);
}

void callBackDemo(){
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
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