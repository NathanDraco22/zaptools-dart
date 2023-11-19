import 'package:zaptools_server/src/server/websocket_connection.dart';

class Room {

  Room(this.name);
  String name;

  final List<WebSocketConnection> _connections = [];

  int get connectionsNumber => _connections.length;

  void add(WebSocketConnection connection) {
    _connections.add(connection);
  }

  void remove(WebSocketConnection connection) {
    _connections.removeWhere((element) => element.id == connection.id);
  }

   void send(
      String eventName, 
      dynamic payload, 
      {Map<String,dynamic>? headers, 
      WebSocketConnection? exclude,
    }) {
    for (var element in _connections) {
      if( exclude != null && exclude.id == element.id){
        continue;
      }
      element.send(eventName, payload, headers: headers);
    }
   }

}

