class SocketEvent{

  final String _event;
  final void Function(dynamic payload) _callback;

  String get event => _event;
  void Function(dynamic payload) get callback => _callback;

  SocketEvent(this._event, this._callback);

}

class AnyEvent {

  final String _event;
  final void Function(String event , dynamic payload) _callback;

  String get event => _event;
  void Function(String event , dynamic payload) get callback => _callback;

  AnyEvent(this._event, this._callback);

}

class EventRef {

  final int _hashId;
  final String _eventName;

  int get hashId => _hashId;
  String get eventName => _eventName;

  EventRef(this._hashId, this._eventName);

}