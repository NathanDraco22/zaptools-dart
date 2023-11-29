import 'package:test/test.dart';
import 'package:zaptools_server/zaptools_server.dart';

import 'webwocket_connection.mock.dart';

void main() {
  group("Room ->", () {
    late Room room;

    setUp(() {
      room = Room("MyRoom");
    });

    test('Test add', () {
      final mockConnection = MockWebSocketConnection("1");
      room.add(mockConnection);
      expect(room.connectionsNumber, equals(1));

      final mockConnection2 = MockWebSocketConnection("2");
      room.add(mockConnection2);
      expect(room.connectionsNumber, equals(2));
    });

    test('Test remove', () {
      final mockConnection = MockWebSocketConnection("1");
      room.add(mockConnection);
      final mockConnection2 = MockWebSocketConnection("2");
      room.add(mockConnection2);

      room.remove(mockConnection);
      expect(room.connectionsNumber, equals(1));
      room.remove(mockConnection2);
      expect(room.connectionsNumber, equals(0));
    });

    test('Test send', () {
      final mockConnection = MockWebSocketConnection("1");
      room.add(mockConnection);
      final mockConnection2 = MockWebSocketConnection("2");
      room.add(mockConnection2);

      room.send("algo", "payload");

      expect(mockConnection.isSendCalled, isTrue);
      expect(mockConnection2.isSendCalled, isTrue);
    });
  });
}
