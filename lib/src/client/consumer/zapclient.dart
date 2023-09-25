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
    log("Connected", name: "ZapClient");
    _subscription = _connectionStream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
           eventInvoker.invoke(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _shareConnectionState(ConnectionState.offline);
          eventInvoker.invoke(EventData("disconnected", {}, {}));
          log("Disconnected", name: "ZapClient");
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
    log("Connected", name: "ZapSubscriber");
    _subscription = _connectionStream.listen(
        (data) {
          final eventData = Validators.convertAndValidate(data);
          _streamController.add(eventData);
        },
        cancelOnError: true,
        onDone: () {
          _shareConnectionState(ConnectionState.offline);
          log("Connected", name: "ZapSubscriber");
          _subscription?.cancel();
        });
  }

  Future<void> clean() async {
    await _streamController.close();
    await _channelSession.close();
  }
}


// class ZapClient {
//   ChannelSession _channelSession;

//   Stream _connectionStream;
//   WebSocketSink _webSocketSink;
//   final EventBook _eventBook;
//   StreamSubscription? _subscription;

//   Function(ConnectionState state)? _connectionListener;

//   final StreamController<EventData> _streamController =
//       StreamController<EventData>.broadcast();

//   final ConnectionStateNotifier _connectionStateNotifier =
//       ConnectionStateNotifier();

//   Stream<ConnectionState> get connectionState =>
//       _connectionStateNotifier.stream;

//   ZapClient(ChannelSession webSocketSession, {required EventBook eventBook})
//       : _eventBook = eventBook,
//         _webSocketSink = webSocketSession.channel.sink,
//         _connectionStream = webSocketSession.channel.stream,
//         _channelSession = webSocketSession;

//   Uri get uri => _channelSession.uri;

//   void onConnectionStateChanged(Function(ConnectionState state) callback) {
//     _connectionListener = callback;
//   }

//   void onEvent(String eventName, EventCallback callback) {
//     _eventBook.saveEvent(Event(eventName, callback));
//   }

//   void sendEvent(String eventName, dynamic payload,
//       {Map<String, dynamic>? headers}) {
//     final data = {
//       "headers": headers ?? {},
//       "eventName": eventName,
//       "payload": payload
//     };
//     final jsonString = json.encode(data);
//     try {
//       _webSocketSink.add(jsonString);
//     } catch (e) {
//       log("Connection Closed unable to send event", level: 800);
//     }
//   }

//   void _invokeEvent(EventData eventData) {
//     final eventName = eventData.name;
//     final event = _eventBook.eventRecords[eventName];
//     if (event == null) return;
//     event.callback(eventData);
//   }

//   void start() async {
//     await _channelSession.channel.ready;
//     _shareConnectionState(ConnectionState.online);
//     _subscription = _connectionStream.listen(
//         (data) {
//           final eventData = Validators.convertAndValidate(data);
//           _invokeEvent(eventData);
//           _streamController.add(eventData);
//         },
//         cancelOnError: true,
//         onDone: () {
//           _shareConnectionState(ConnectionState.offline);
//           _subscription?.cancel();
//           _webSocketSink.close();
//         });
//   }

//   void _updateSession(ChannelSession webSocketSession) {
//     _channelSession = webSocketSession;
//     _webSocketSink = webSocketSession.channel.sink;
//     _connectionStream = webSocketSession.channel.stream;
//   }

//   void _shareConnectionState(ConnectionState state) {
//     if (_connectionListener != null) {
//       _connectionListener!(state);
//     }
//     _connectionStateNotifier.emit(state);
//   }

//   Stream<EventData> subscribeToEvent(String eventName) =>
//       _streamController.stream.where((event) => event.name == eventName);

//   Stream<EventData> subscribeToAllEvent() => _streamController.stream;

//   Stream<EventData> subscribeToEvents(List<String> eventNames) {
//     return _streamController.stream
//         .where((event) => eventNames.contains(event.name));
//   }

//   Future<void> disconnect() async {
//     await _webSocketSink.close();
//   }

//   Future<void> clean() async {
//     await _streamController.close();
//     await _webSocketSink.close();
//   }
// }
