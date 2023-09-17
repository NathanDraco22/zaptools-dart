import 'package:zaptools/zaptools_client.dart';

void main() {
  Uri uri = Uri.parse("ws://127.0.0.1:8000/ws");
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print("client connected");
  });

  zapClient.onDisconnected((eventData) {
    print("connection lost!");
    ClientConnector.tryReconnect(zapClient);
  });

  zapClient.start();
}
