import 'package:zaptools_server/src/server/websocket_connection.dart';

import '../meta/meta_tag.dart';

/// A group of connections
class Room {
  Room(this.name);
  String name;

  final Map<String,WebSocketConnection> _connections = {};
  final Map<String, MetaTag> _meta = {};

  int get connectionsNumber => _connections.length;
  
  /// Add a connection to the room.
  /// 
  /// [metaTag] is for including extra information.
  void add(WebSocketConnection connection,{MetaTag? metaTag }){
    if(metaTag !=null){
      _meta[connection.id] = metaTag;
    }
    _connections[connection.id] = connection;
  }

  /// Remove connection and metatag from the room.
  void remove(WebSocketConnection connection) {
    _connections.remove(connection.id);
    _meta.remove(connection.id);
  }

  /// [send] a event to all room
  /// 
  /// [exclude] parameter for excluding a connection
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

  /// get [MetaTag] from a connection if exist in the room.
  MetaTag? getMeta(WebSocketConnection connection) 
    => _meta[connection.id];
}
