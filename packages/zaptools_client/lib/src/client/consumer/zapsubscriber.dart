import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zaptools_client/src/client/connection_state_notifier.dart';
import 'package:zaptools_client/src/shared/helper.dart';
import 'package:zaptools_client/zaptools_client.dart';

import 'zapclient.dart';

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
    log("Connecting...", name: "Zap");
    Future.microtask(
      ()=>_shareConnectionState(ZapClientState.connecting)
    );
    final uri = Uri.parse(url);
    late WebSocketChannel channel;
    try {
      channel = WebSocketChannel.connect(uri, protocols:  protocols);
      await channel.ready;
    } catch (e) {
      log("Failed connection to the server",name: "Zap", error:  e.toString());
      throw Exception("Unable to connect to the server\n${e.toString()}");
    }
    _session = (webSocketSink: channel.sink, stream: channel.stream);
    log("Connected", name: "Zap");
    _start();
  }

  @override
  Future<void> disconnect() async {
    await _session?.webSocketSink.close();
  }

  Future<void> tryReConnect(Duration period, {Iterable<String>? protocols}) async {
    await Future.delayed(period);
    try {
      await connect(protocols: protocols);
    } catch (e) {
      log("Unable to reconnect", name: "Zap");
    }
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
  Future<void> sendEvent(String eventName, dynamic payload,
      {Map<String, dynamic>? headers}) async {
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
  /// [ZapClientState.connecting]
  ///
  /// [ZapClientState.online]
  ///
  /// [ZapClientState.offline]
  ///
  /// [ZapClientState.error]
  ///
  /// [ZapClientState.retrying]
  Stream<ZapClientState> get connectionState =>
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
    log("Online", name: "Zap");
    Future(() {
      _shareConnectionState(ZapClientState.online);
    });
    _subscription = stream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
          _eventDataStream.add(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _subscription?.cancel();
          log("Offline", name: "Zap");
          _shareConnectionState(ZapClientState.offline);
        });
  }

  void _shareConnectionState(ZapClientState state) {
    _connectionStateNotifier.emit(state);
  }
}
