import 'dart:async';
import "dart:convert";
import 'dart:developer';

import "package:web_socket_channel/web_socket_channel.dart";
import 'package:zaptools/src/client/connection_state.dart';

import '../../shared/event_tools.dart';
import '../connection_state_notifier.dart';
import '../websocket_session.dart';
import '../../shared/helper.dart';

part 'zapclient.dart';
part 'consumer.dart';

class ClientConnector {
  static ZapClient connect(
    Uri uri, {
    Iterable<String>? protocols,
    EventBook? eventBook,
    bool autoStart = true
  }) {
    final channel = WebSocketChannel.connect(uri, protocols: protocols);
    final session = ChannelSession.fromWebSocketChannel(channel, uri);
    return ZapClient(
      session, 
      eventBook: eventBook ?? EventBook(), 
      autoStart: autoStart
    );
  }

  static ZapSubscriber attach(
    Uri uri, 
    {Iterable<String>? protocols, 
    bool autoStart = true}
  ) {
    final channel = WebSocketChannel.connect(uri, protocols: protocols);
    final session = ChannelSession.fromWebSocketChannel(channel, uri);
    return ZapSubscriber(session, autoStart: autoStart);
  }

  static void tryReconnect(ZapConsumer client) async {
    client._shareConnectionState(ConnectionState.retrying);
    await client.disconnect();
    final uri = client.uri;
    late WebSocketChannel channel;
    try {
      channel = WebSocketChannel.connect(uri);
    } catch (e) {
      log("Unable to reconnect", level: 800);
      return;
    }
    final session = ChannelSession.fromWebSocketChannel(channel, uri);
    client._updateSession(session);
    client.start();
  }
}
