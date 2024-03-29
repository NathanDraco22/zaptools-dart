import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'package:zaptools_server/src/shared/event_tools.dart';

import '../../shared/helper.dart';
import '../tools/event_context.dart';
import '../tools/event_register_mixin.dart';
import '../tools/event_tools.dart';
import '../websocket_connection.dart';

class ZapServer with ZapServerRegister {
  final dynamic address;
  final int port;
  final String path;
  final bool shared;
  final int backlog;

  late EventCaller _eventCaller;
  HttpServer? _server;
  StreamSubscription? _subscription;

  ZapServer({
    this.address = '0.0.0.0',
    this.port = 8000,
    this.path = "/",
    this.shared = true,
    this.backlog = 0,
  }) {
    _eventCaller = EventCaller(eventBook);
  }

  Future<HttpServer> start() async {
    final server = await HttpServer.bind(
      address,
      port,
      backlog: backlog,
      shared: shared,
    );

    server.listen((HttpRequest req) async {
      if (req.uri.path == path && WebSocketTransformer.isUpgradeRequest(req)) {
        _connectionUpgrade(req);
        return;
      }
      final response = req.response;
      response.statusCode = 400;
      await response.close();
      return;
    });
    _server = server;
    log("Server Started", name: "ZapServer");
    return server;
  }

  Future<void> close() async {
    if (_server != null) return;
    await _server!.close();
  }

  Future<void> _connectionUpgrade(HttpRequest req) async {
    final webSocket = await WebSocketTransformer.upgrade(req);
    log("Websocket Upgraded", name: "ZapServer");
    final conn = WebSocketConnection.io("id", webSocket);
    log("Websocket Connected", name: "ZapServer");
    final connectedData = EventData("connected", {}, {});
    _eventCaller.triggerEvent(EventContext(connectedData, conn));
    _subscription = webSocket.listen(
      (onData) => _handleData(onData, conn),
      onDone: (){
        final disconnectedData = EventData("disconnected", {}, {});
        final disconnectedContext = EventContext(disconnectedData, conn);
        _eventCaller.triggerEvent(disconnectedContext);
        _subscription?.cancel();
      }
    );

  }

  void _handleData(dynamic onData, WebSocketConnection connection) {
    final eventData = Validators.convertAndValidate(onData);
    final ctx = EventContext(eventData, connection);
    _eventCaller.triggerEvent(ctx);
  }
}
