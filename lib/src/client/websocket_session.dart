import "package:web_socket_channel/web_socket_channel.dart";

class ChannelSession {
  final WebSocketChannel channel;
  final Uri uri;
  ChannelSession(this.channel, this.uri);
}