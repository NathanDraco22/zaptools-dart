import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zaptools_client/src/shared/event_tools.dart';
import 'package:zaptools_client/src/shared/helper.dart';
import 'package:zaptools_client/zaptools_client.dart';

import 'zapclient.dart';

/// A client based on Callbacks.
///
/// Provides Callbacks for the events and state of connection.
class ZapConsumer extends ZapClient {
  Function(ZapClientState state)? _connectionListener;
  final EventBook _eventBook;

  SessionRecord? _session;
  StreamSubscription? _subscription;

  ZapConsumer(super.url,)
      : _eventBook = EventBook();

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
      log(
        "Failed connection to the server",
        name: "Zap", 
        error: e.toString()
      );
      Future.microtask(
        ()=>_shareConnectionState(ZapClientState.error)
      );
      throw Exception("Unable to connect to the server\n${e.toString()}");
    }
    _session = (webSocketSink: channel.sink, stream: channel.stream);
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

  @override
  Future<void>sendEvent(String eventName, dynamic payload,
      {Map<String, dynamic>? headers}) async{
    final data = {
      "headers": headers ?? {},
      "eventName": eventName,
      "payload": payload
    };
    try {
      final jsonString = json.encode(data);
      _session!.webSocketSink.add(jsonString);
    } catch (e) {
      throw Exception("sendEvent was called and ZapConsumer is not connected");
    }
  }

  // CallBack when ZapConsumer is connected
  void onConnected(EventCallback callback) {
    _eventBook.saveEvent(Event("connected", callback));
  }

  // CallBack when ZapConsumer is disconnected
  void onDisconnected(EventCallback callback) {
    _eventBook.saveEvent(Event("disconnected", callback));
  }

  // CallBack when ZapConsumer receives an event
  void onEvent(String eventName, EventCallback callback) {
    _eventBook.saveEvent(Event(eventName, callback));
  }

  /// Callback when connection state has changed.
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
  void onConnectionStateChanged(Function(ZapClientState state) callback) {
    _connectionListener = callback;
  }

  void _shareConnectionState(ZapClientState state) {
    if (_connectionListener != null) {
      _connectionListener!(state);
    }
  }

  Future<void> _start() async {
    final stream = _session?.stream;
    if (stream == null) return;
    final eventInvoker = EventInvoker(_eventBook);
    log("Online", name: "Zap");
    Future.microtask(
      () {
        _shareConnectionState(ZapClientState.online);
        eventInvoker.invoke(EventData.fromEventName("connected"));
      } 
    );
    
    _subscription = stream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
          eventInvoker.invoke(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _shareConnectionState(ZapClientState.offline);
          eventInvoker.invoke(EventData.fromEventName("disconnected"));
          log("Offline", name: "Zap");
          _subscription?.cancel();
        });
  }
}
