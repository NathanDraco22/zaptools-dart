import "package:web_socket_channel/web_socket_channel.dart";

class WebSocketSession {
  final WebSocketChannel channel;
  final Uri uri;
  WebSocketSession(this.channel, this.uri);
}