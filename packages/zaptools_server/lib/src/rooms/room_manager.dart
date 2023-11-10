
import 'room.dart';
import '../server/websocket_connection.dart';

class RoomManager {

  final Map<String, Room> _roomBook = {};


  void addRoom(Room room){
    _roomBook[room.name] = room;
  }

  void removeRoom(Room room){
    _roomBook.remove(room.name);
  }

  void sendToRoom(
    String roomName, 
    {
      required String eventName, 
      required dynamic payload, 
      Map<String,dynamic>? headers
    }){
      final room = _roomBook[roomName];
      if(room == null) return;
      room.send(eventName, payload, headers: headers);
    }
  
  void addToRoom(String roomName, WebSocketConnection connection){
    final room = _roomBook[roomName]; 
    if(room == null){
      final newRoom = Room(roomName);
      newRoom.add(connection);
      _roomBook[newRoom.name] = newRoom;
      return;
    }
    room.add(connection);
  }

}