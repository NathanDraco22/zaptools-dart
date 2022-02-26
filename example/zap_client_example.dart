import 'package:zap_client/zap_client.dart';

void main() {

  final Uri uri = Uri.parse("ws://localhost:8000/");

  final ZapSocketClient ws = ZapSocketClient.connectTo(uri);

  ws.onConnected(() => ws.send('myEvent', "This a message"));

  ws.onDisconnected(() => print("Disconnected"));

}
