import 'package:zap_client/zap_client.dart';
void main() {

  //Connect to localhost websocket server.
  final Uri uri = Uri.parse("ws://localhost:8000/");
  final ZapSocketClient ws = ZapSocketClient.connectTo(uri);

  //trigger when connected
  ws.onConnected(() => ws.send('myEvent', "This a message"));
  //trigger when disconnected
  ws.onDisconnected(() => print("Disconnected"));

  //listening when receive "eventFromServer"
  ws.onEventStream("eventFromServer", (payload) { 
    //do something
    print(payload);
  });

  //Send a event to server
  ws.send("eventToServer", "DATA");

  ws.anyEventStream.listen((data) {
    //listening all events
    print(data.event); //get event name
    print(data.payload); //get payload
  });

}
