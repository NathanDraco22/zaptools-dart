import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:zaptools/src/client/consumer/client_connector.dart';
import 'package:zaptools/src/client/websocket_session.dart';
import 'package:zaptools/src/shared/event_tools.dart';

@GenerateNiceMocks([MockSpec<ChannelSession>()])
import 'zaptools_test.mocks.dart';

void main() {

  group('Test ZapClient', () {

    ZapClient? zapClient;

    final mockChannelSession = MockChannelSession();

    setUp(() {
      zapClient = ZapClient(mockChannelSession, eventBook: EventBook());
    });

    tearDown(() {
      zapClient?.disconnect();
      zapClient = null;
    });

    test('onConnected', () async {
      when(mockChannelSession.stream).thenAnswer((_) => Stream.empty());
      zapClient?.onConnected((eventData) {
        expect(eventData.name, "connected");
      });
    });

    test('onDisconnected', () async {
      when(mockChannelSession.stream).thenAnswer((_) => Stream.empty());
      zapClient?.onDisconnected((eventData) {
        expect(eventData.name, "disconnected");
      });
    });
  });

  
}
