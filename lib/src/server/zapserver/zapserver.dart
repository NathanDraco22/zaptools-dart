import 'dart:io';

import 'package:zaptools/src/server/event_context.dart';
import 'package:zaptools/src/server/event_tools_server.dart';
import 'package:zaptools/src/server/websocket_connection.dart';
import 'package:zaptools/src/shared/helper.dart';

class ZapServer with ZapRegister {
  final dynamic address;
  final int port;
  final String path;
  final bool shared;
  final int backlog;


  late EventCaller _eventCaller;

  ZapServer({
    this.address = '0.0.0.0',
    this.port = 8000,
    this.path = "/",
    this.shared = true,
    this.backlog = 0,
  }){
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
      if (!WebSocketTransformer.isUpgradeRequest(req)){
        final response = req.response;
        response.statusCode = 400;
        response.write("WebSocket Server");
        await response.close();
        return;
      }
      if (req.uri.path == path) {
        _connectionUpgrade(req);
      }
     });

     return server;

  }


  Future<void> _connectionUpgrade(HttpRequest req)async{
    final webSocket = await WebSocketTransformer.upgrade(req);
    final conn = WebSocketConnection.io("id", webSocket);
    webSocket.listen((onData) => _handleData(onData, conn));
  }

  void _handleData(dynamic onData, WebSocketConnection connection) {
    final eventData = Validators.convertAndValidate(onData);
    final ctx = EventContext(eventData, connection);
    _eventCaller.triggerEvent(ctx);
  } 

}