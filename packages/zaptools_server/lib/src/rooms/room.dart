import 'package:zaptools_server/src/server/websocket_connection.dart';

import '../meta/meta_tag.dart';

class Room {
  Room(this.name);
  String name;

  final Map<String,WebSocketConnection> _connections = {};
  final Map<String, MetaTag> _meta = {};

  int get connectionsNumber => _connections.length;

  void add(WebSocketConnection connection,{MetaTag? metaTag }){
    if(metaTag !=null){
      _meta[connection.id] = metaTag;
    }
    _connections[connection.id] = connection;
  }

  void remove(WebSocketConnection connection) {
    _connections.remove(connection.id);
    _meta.remove(connection.id);
  }

  void send(
    String eventName,
    dynamic payload, {
    Map<String, dynamic>? headers,
    WebSocketConnection? exclude,
  }) {
    for (var element in _connections.values) {
      if (exclude != null && exclude.id == element.id) {
        continue;
      }
      element.send(eventName, payload, headers: headers);
    }
  }

  MetaTag? getMeta(WebSocketConnection connection) 
    => _meta[connection.id];
}
