import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zaptools_client/src/client/connection_state_notifier.dart';
import 'package:zaptools_client/src/shared/helper.dart';
import 'package:zaptools_client/zaptools_client.dart';

/// A client based on Streams.
///
/// Provides Streams for the events and state of connection.
class ZapSubscriber extends ZapClient {
  ZapSubscriber(super.url);

  SessionRecord? _session;
  StreamSubscription? _subscription;

  final StreamController<EventData> _eventDataStream =
      StreamController<EventData>.broadcast();

  final ConnectionStateNotifier _connectionStateNotifier =
      ConnectionStateNotifier();

  @override
  Future<void> connect({Iterable<String>? protocols}) async {
    log("Connecting...", name: "ZapSubscriber");
    _shareConnectionState(ConnectionState.connecting);
    final uri = Uri.parse(url);
    final channel = WebSocketChannel.connect(uri);
    await channel.ready;
    _session = (webSocketSink: channel.sink, stream: channel.stream);
    log("Online", name: "ZapSubscriber");
    _shareConnectionState(ConnectionState.online);
    _start();
  }

  @override
  Future<void> disconnect() async {
    await _session?.webSocketSink.close();
  }

  /// Disconnect and clean the [ZapSubscriber].
  ///
  /// [disconnect] is called internally.
  Future<void> clean() async {
    await disconnect();
    await _eventDataStream.close();
    await _connectionStateNotifier.close();
    await _session?.webSocketSink.close();
  }

  @override
  sendEvent(String eventName, dynamic payload,
      {Map<String, dynamic>? headers}) {
    final data = {
      "headers": headers ?? {},
      "eventName": eventName,
      "payload": payload
    };
    try {
      final jsonString = json.encode(data);
      _session!.webSocketSink.add(jsonString);
    } catch (e) {
      throw Exception(
          "sendEvent was called and ZapSubscriber is not connected");
    }
  }

  /// Stream of connection states
  ///
  /// [ConnectionState.connecting]
  ///
  /// [ConnectionState.online]
  ///
  /// [ConnectionState.offline]
  ///
  /// [ConnectionState.error]
  ///
  /// [ConnectionState.retrying]
  Stream<ConnectionState> get connectionState =>
      _connectionStateNotifier.stream;

  ///Stream of a single event
  Stream<EventData> subscribeToEvent(String eventName) =>
      _eventDataStream.stream.where((event) => event.name == eventName);

  ///Stream of all events
  Stream<EventData> subscribeToAllEvent() => _eventDataStream.stream;

  ///Stream of the event names given
  Stream<EventData> subscribeToEvents(List<String> eventNames) {
    return _eventDataStream.stream
        .where((event) => eventNames.contains(event.name));
  }

  _start() {
    final stream = _session?.stream;
    if (stream == null) return;
    _subscription = stream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
          _eventDataStream.add(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _subscription?.cancel();
          log("Offline", name: "ZapSubscriber");
          _shareConnectionState(ConnectionState.offline);
        });
  }

  void _shareConnectionState(ConnectionState state) {
    _connectionStateNotifier.emit(state);
  }
}
