import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zaptools_client/src/client/connection_state.dart';

typedef SessionRecord = ({WebSocketSink webSocketSink, Stream stream});

abstract class ZapClient {
  ZapClient(this.url);
  //URL used for connecting to the server.
  final Uri url;

  /// The current connection state.
  /// [ZapClientState.connecting]
  ///
  /// [ZapClientState.online]
  ///
  /// [ZapClientState.offline]
  ///
  /// [ZapClientState.error]
  ///
  ZapClientState get currentConnectionState;

  /// Connect to the server.
  ///
  /// The optional [protocols] parameter is the same as WebSocket.connect.
  Future<void> connect({Iterable<String>? protocols});

  /// disconnect from the websocket session.
  Future<void> disconnect();

  /// Send event to the server
  ///
  /// Must no be called if [ZapClient] is not connected
  Future<void> sendEvent(String eventName, dynamic payload, {Map<String, dynamic>? headers});
}
