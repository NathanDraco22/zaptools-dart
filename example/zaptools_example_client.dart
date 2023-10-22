import 'package:zaptools_client/zaptools_client.dart';

void main() {

callBackDemo();
// subcribersDemo();
  
}


void subcribersDemo(){
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.attach(uri);

  zapClient.connectionState.listen((event) {
    // code here
    // No received event after clean
  });

  zapClient.subscribeToEvent("myEVent").listen((eventData){
    // code here
    // No received event after clean
  });

  zapClient.clean();

  ClientConnector.tryReconnect(zapClient);

}

void callBackDemo(){
  Uri uri = Uri.parse("ws://127.0.0.1:8000/");
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print("client connected oh yeah!");
    Future.delayed(Duration(seconds: 3)).then((value) => zapClient.disconnect());
   });

  zapClient.onDisconnected((eventData) {
    print("Cliente disconnected bye bye");
  });

  zapClient.sendEvent("hello", "hello from client");

  zapClient.onEvent("saludo", (eventData) {
    print(eventData.name);
    print(eventData.payload);
  },);
}