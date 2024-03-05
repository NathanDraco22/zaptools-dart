import 'dart:async';

import 'connection_state.dart';

class ConnectionStateNotifier {
  final StreamController<ZapClientState> _streamController =
      StreamController.broadcast();

  Stream<ZapClientState> get stream => _streamController.stream;

  void emit(ZapClientState connectionState) {
    _streamController.add(connectionState);
  }

  Future<void> close() async {
    await _streamController.close();
  }
}
