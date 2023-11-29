import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

typedef SessionRecord = ({WebSocketSink webSocketSink, Stream stream});

abstract class ZapClient {
  ZapClient(this.url);
  //URL used for connecting to the server.
  final String url;

  /// Connect to the server.
  ///
  /// The optional [protocols] parameter is the same as WebSocket.connect.
  Future<void> connect({Iterable<String>? protocols});

  /// disconnect from the websocket session.
  Future<void> disconnect();

  /// Send event to the server
  ///
  /// Must no be called if [ZapClient] is not connected
  sendEvent(String eventName, dynamic payload, {Map<String, dynamic>? headers});
}
