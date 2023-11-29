import 'package:zaptools_server/src/server/websocket_connection.dart';

class MockWebSocketConnection implements WebSocketConnection {
  MockWebSocketConnection(String id) : _id = id;

  bool isClosedCalled = false;
  bool isSendCalled = false;
  final String _id;

  @override
  void close() => isClosedCalled = true;

  @override
  String get id => _id;

  @override
  void send(String eventName, payload, {Map<String, dynamic>? headers}) =>
      isSendCalled = true;
}
