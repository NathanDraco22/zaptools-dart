import "package:web_socket_channel/web_socket_channel.dart";

class ChannelSession {
  final WebSocketSink sink;
  final Stream stream;
  final Uri uri;
  final Future<void> ready;
  ChannelSession(this.uri, this.sink, this.stream, this.ready);

  ChannelSession.fromWebSocketChannel( WebSocketChannel webSocketChannel, this.uri):
    sink = webSocketChannel.sink,
    stream = webSocketChannel.stream,
    ready = webSocketChannel.ready;
}