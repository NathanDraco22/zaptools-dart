import 'dart:async';

enum ConnectionState { online, offline, retrying }

class ConnectionStateNotifier {
  final StreamController<ConnectionState> _streamController =
      StreamController.broadcast();

  Stream<ConnectionState> get stream => _streamController.stream;

  void emit(ConnectionState connectionState) {
    _streamController.add(connectionState);
  }
}
