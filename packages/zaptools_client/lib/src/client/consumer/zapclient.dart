part of 'client_connector.dart';


class ZapClient extends ZapConsumer {
  Function(ConnectionState state)? _connectionListener;
  final EventBook _eventBook;
  final bool autoStart;

  ZapClient(super.channelSession, {required EventBook eventBook, this.autoStart = true})
      : _eventBook = eventBook {
        if (autoStart) start();
      }

  void onConnected(EventCallback callback){
    _eventBook.saveEvent(Event("connected", callback));
  }

  void onDisconnected(EventCallback callback){
    _eventBook.saveEvent(Event("disconnected", callback));
  }

  void onEvent(String eventName, EventCallback callback) {
    _eventBook.saveEvent(Event(eventName, callback));
  }

  void onConnectionStateChanged(Function(ConnectionState state) callback) {
    _connectionListener = callback;
  }

  @override
  void _shareConnectionState(ConnectionState state) {
    if (_connectionListener != null) {
      _connectionListener!(state);
    }
  }

  @override
  Future<void> start() async {
    await _channelSession.ready;
    final eventInvoker = EventInvoker(_eventBook);
    _shareConnectionState(ConnectionState.online);
    eventInvoker.invoke(EventData("connected", {}, {}));
    log("Online", name: "ZapClient");
    _subscription = _connectionStream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
           eventInvoker.invoke(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _shareConnectionState(ConnectionState.offline);
          eventInvoker.invoke(EventData("disconnected", {}, {}));
          log("Offline", name: "ZapClient");
          _subscription?.cancel();
        });
  }
}

class ZapSubscriber extends ZapConsumer {
  
  bool autoStart;
  
  final StreamController<EventData> _streamController =
      StreamController<EventData>.broadcast();

  final ConnectionStateNotifier _connectionStateNotifier =
      ConnectionStateNotifier();

    

  ZapSubscriber(super.channelSession, {this.autoStart = true}) {
    if (autoStart) start();
  }

  Stream<ConnectionState> get connectionState =>
      _connectionStateNotifier.stream;

  Stream<EventData> subscribeToEvent(String eventName) =>
      _streamController.stream.where((event) => event.name == eventName);

  Stream<EventData> subscribeToAllEvent() => _streamController.stream;

  Stream<EventData> subscribeToEvents(List<String> eventNames) {
    return _streamController.stream
        .where((event) => eventNames.contains(event.name));
  }

  @override
  void _shareConnectionState(ConnectionState state) {
    _connectionStateNotifier.emit(state);
  }

  @override
  Future<void> start() async {
    await _channelSession.ready;
    Future(() => _shareConnectionState(ConnectionState.online));
    log("Online", name: "ZapSubscriber");
    _subscription = _connectionStream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
          _streamController.add(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _shareConnectionState(ConnectionState.offline);
          log("Offline", name: "ZapSubscriber");
          _subscription?.cancel();
        });
  }

  Future<void> clean() async {
    await _streamController.close();
    await _channelSession.close();
  }
}