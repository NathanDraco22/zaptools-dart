

part of 'client_connector.dart';

abstract class ZapConsumer {
  ChannelSession _channelSession;
  Stream _connectionStream;
  WebSocketSink _webSocketSink;
  StreamSubscription? _subscription;

  ZapConsumer(this._channelSession)
      : _connectionStream = _channelSession.channel.stream,
        _webSocketSink = _channelSession.channel.sink;

  Uri get uri => _channelSession.uri;

  void sendEvent(String eventName, dynamic payload,
      {Map<String, dynamic>? headers}) {
    final data = {
      "headers": headers ?? {},
      "eventName": eventName,
      "payload": payload
    };
    final jsonString = json.encode(data);
    try {
      _webSocketSink.add(jsonString);
    } catch (e) {
      log("Connection Closed unable to send event", level: 800);
    }
  }

  Future<void> start();

  void _updateSession(ChannelSession webSocketSession) {
    _channelSession = webSocketSession;
    _webSocketSink = webSocketSession.channel.sink;
    _connectionStream = webSocketSession.channel.stream;
  }

  void _shareConnectionState(ConnectionState state);

  Future<void> disconnect() async {
    await _webSocketSink.close();
  }
}