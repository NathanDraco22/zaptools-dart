import 'package:zaptools/zaptools.dart';

void main() {
  Uri uri = Uri.parse("ws://127.0.0.1:8000/ws");
  WebSocketServices().connect(uri);
}
