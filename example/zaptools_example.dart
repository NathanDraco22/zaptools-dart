import 'package:zaptools/src/client/connection_state.dart';
import 'package:zaptools/zaptools_client.dart';

void main() {
  Uri uri = Uri.parse("ws://127.0.0.1:3000/ws");
  final zapClient = ClientConnector.connect(uri);

  zapClient.connectionState.listen(print);

  zapClient.onConnectionStateChanged((state) {
    if (state case ConnectionState.online) {
      print("client connected");
    }
  });

  zapClient.onEvent("saludo", (eventData) {
    print(eventData.payload);
  });

  zapClient.start();
}
