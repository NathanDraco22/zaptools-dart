

part of 'client_connector.dart';

abstract class ZapConsumer {
  ChannelSession _channelSession;
  Stream _connectionStream;
  StreamSubscription? _subscription;

  ZapConsumer(this._channelSession)
      : _connectionStream = _channelSession.stream;

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
      _channelSession.add(jsonString);
    } catch (e) {
      log("Connection Closed unable to send event", level: 800);
    }
  }

  Future<void> start();

  void _updateSession(ChannelSession webSocketSession) {
    _channelSession = webSocketSession;
    _connectionStream = webSocketSession.stream;
  }

  void _shareConnectionState(ConnectionState state);

  Future<void> disconnect() async {
    await _channelSession.close();
  }
}