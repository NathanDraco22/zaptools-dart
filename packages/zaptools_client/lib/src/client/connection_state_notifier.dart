import 'dart:async';

import 'connection_state.dart';

class ConnectionStateNotifier {
  final StreamController<ConnectionState> _streamController =
      StreamController.broadcast();

  Stream<ConnectionState> get stream => _streamController.stream;

  void emit(ConnectionState connectionState) {
    _streamController.add(connectionState);
  }

  Future<void> close() async {
    await _streamController.close();
  }
}
