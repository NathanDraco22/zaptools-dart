import 'dart:async';

import 'package:mockito/annotations.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:zaptools/src/client/consumer/client_connector.dart';
import 'package:zaptools/src/client/websocket_session.dart';
import 'package:zaptools/src/shared/event_tools.dart';

import 'zaptools_test.mocks.dart';
import 'zaptool_server_data.mock.dart';

@GenerateNiceMocks([MockSpec<ChannelSession>()])
void main() {

  group('Test ZapClient ->', () {

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


  group("Test ZapSubscriber ->", (){
    ZapSubscriber? zapSubscriber;
    final mockChannelSession = MockChannelSession();

    tearDown(() => zapSubscriber = null);

    test("subscribeToAllEvent", (){
      when(mockChannelSession.stream).thenAnswer(
        (realInvocation) => Stream.fromIterable(mockData)
      );
      zapSubscriber = ZapSubscriber(mockChannelSession);
      final allEventStream =  zapSubscriber!.subscribeToAllEvent();
      final unPackStream = allEventStream.map((event) => event.name);
      final unPackStreamPayload = allEventStream.map((event) => event.payload,);
      final unPackStreamHeader = allEventStream.map((event) => event.headers["myHeader"],);
      expect(unPackStream, emitsInOrder(["event1", "event2", "event3"]));
      expect(unPackStreamPayload, emitsInOrder(["payload1", "payload2", "payload3"]));
      expect(unPackStreamHeader, emitsInOrder(["header1", "header2", "header3"]));
    });

    test("subscribeToEvent", () async{
      when(mockChannelSession.stream).thenAnswer(
        (realInvocation) => Stream.fromIterable(mockDataEvent));
      zapSubscriber = ZapSubscriber(mockChannelSession);
      final listenEvent1 = zapSubscriber!.subscribeToEvent("event1");
      final listenEvent2 = zapSubscriber!.subscribeToEvent("event2");
      final listenEvent3 = zapSubscriber!.subscribeToEvent("event3");
      final unPackStream = listenEvent1.map((event) => event.name);
      final unPackStream2 = listenEvent2.map((event) => event.name);
      final unPackStream3 = listenEvent3.map((event) => event.name);
      expect(unPackStream, emitsInOrder(["event1","event1","event1"]));
      expect(unPackStream2, emitsInOrder(["event2","event2"]));
      expect(unPackStream3, emitsInOrder(["event3","event3","event3","event3"]));
    });

    test("subscribeToEvents", () {
      when(mockChannelSession.stream).thenAnswer(
        (realInvocation) => Stream.fromIterable(mockDataEvent));
      zapSubscriber = ZapSubscriber(mockChannelSession);
      final listenEvents = zapSubscriber!.subscribeToEvents(["event1", "event3"]);
      final unPackEvents = listenEvents.map((event) => event.name);
      expect(unPackEvents, emitsInOrder(
        ["event1","event3","event1","event1","event3","event3","event3",]));
    });
  });

  
}
