import 'package:zap_client/zap_client.dart';

void main() {

  final Uri uri = Uri.parse("ws://localhost:8000/");

  final ZapSocketClient ws = ZapSocketClient.connectTo(uri: uri);

  ws.onConnected(() => ws.send('myEvent', "This a message"));

  ws.onEvent("eventFromServer", (payload) => print(payload));

  ws.onAnyEvent((event, payload) => print([event , payload]));

  ws.onDisconnected(() => print("Disconnected"));

}
