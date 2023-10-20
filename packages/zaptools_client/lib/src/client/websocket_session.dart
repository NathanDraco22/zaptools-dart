import "package:web_socket_channel/web_socket_channel.dart";

class ChannelSession {
  final WebSocketSink _sink;
  final Stream _stream;
  final Uri uri;
  final Future<void> ready;
  ChannelSession(this.uri, WebSocketSink sink, Stream stream, this.ready):
    _sink = sink,
    _stream = stream
  ;

  Stream get stream => _stream;

  void add(dynamic data){
    _sink.add(data);
  }

  Future<void> close([int? closeCode, String? closeReason])async{
    await _sink.close(closeCode,closeReason);
  }

  ChannelSession.fromWebSocketChannel( WebSocketChannel webSocketChannel, this.uri):
    _sink = webSocketChannel.sink,
    _stream = webSocketChannel.stream,
    ready = webSocketChannel.ready;
}