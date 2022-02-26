import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/socket_event.dart';
import 'models/zap_data_model.dart';
import 'sockets_class/event_manager.dart';
import 'sockets_class/socket_interface.dart';

enum SocketState{
  online,
  offline,
}

class ZapSocketClient implements WebSocketInterface{

//----------------------PROPERTIES----------------------------------------------

  SocketState socketState = SocketState.offline;

  final StreamController<SocketData> _anyEventStream = StreamController.broadcast();

  Stream<SocketData> get anyEventStream => _anyEventStream.stream;

  void disposeStreamSocketData(){
    _anyEventStream.close();
  }

  late Uri _uri;
  
  WebSocketChannel? _webSocketChannel;
  AnyEvent? _anySocketEvent;

  String? _idConnection;
  
  Function? _onConnectedCallback;
  Function? _onDisconnectedCallback;
  Function? _isAboutDisconnectedCallback;

  static final ZapSocketClient _webSocketClient = ZapSocketClient._private();

  String? get idConnection => _idConnection;

  @override
  List<SocketEvent> socketEvents = [];

  @override
  String? get protocol {
    return _webSocketChannel?.protocol;
  }

//-------------------- CONSTRUCTOR----------------------------------------------

  ZapSocketClient._private();

  ZapSocketClient.newInstance(this._uri){
    tryConnection(_uri);
  }
  
  factory ZapSocketClient.connectTo(Uri? uri){

    if(uri == null) return _webSocketClient;

    _webSocketClient._uri = uri;
    _webSocketClient.tryConnection(uri);

    return _webSocketClient;
  }

  factory ZapSocketClient.getSingleton(){
    return _webSocketClient;
  }

//--------------------------------------METHODS---------------------------------
  //************************ */
  void tryConnection(Uri uri){
    if (socketState == SocketState.online) return;

    _webSocketChannel = WebSocketChannel.connect(uri);

    _webSocketChannel?.stream.listen(

      _eventController,

      cancelOnError: true,
      onDone:  _onClosedSocket,
      onError: _onConnectionFail 
    );
  }
  //********************** */

  @override
  void disconnect(){
    _onTerminated();
    socketState = SocketState.offline;
  }

  @override
  void onConnected( void Function() callback){
    _onConnectedCallback = callback;
  }

  @override
  EventRef onEvent(String eventName, void Function(dynamic payload) callback ){
    final SocketEvent socketEvent = SocketEvent(eventName, callback);
    socketEvents.add(socketEvent); 
    return EventRef(socketEvent.hashCode, socketEvent.event);
  }
  @override
  StreamSubscription<SocketData> onEventStream(String eventName, void Function(dynamic payload) callback){
    print("REGISTRADO ELEMENTO");
    final sub = anyEventStream.listen((data) {
      if ( data.event != eventName ) return;
      callback(data.payload);
    });

    return sub ;
  }

  @override
  void onAnyEvent(void Function(String event ,dynamic payload) callback) {
    final AnyEvent socketEvent = AnyEvent("-", callback);
    _anySocketEvent = socketEvent ;
  }

  @override
  void send(String eventName , dynamic payload){

    if ( _idConnection == null ) return;

    final toSend = ZapSocketData(
      zapId: _idConnection ?? "",
      zapAdapter: "Dart client",
      event: eventName,
      payload: payload );

    _webSocketChannel?.sink.add(toSend.toJsonEncoded());
  }

  @override
  void isAboutDisconnected(void Function() callback ){
    _isAboutDisconnectedCallback = callback;
  }

  @override
  void onDisconnected( void Function() onDisconnected){
    _onDisconnectedCallback = onDisconnected;
  }

  @override
  void deleteEvent(EventRef ref ){
    socketEvents.removeWhere((element) => element.hashCode == ref.hashId );
  }

//------------------------------------------------------------------------------
  //*************************************
  void _eventController( dynamic event ){

    final isPassProtocol = EventManager.checkZapProtocol(event, _webSocketChannel!);

    if (!isPassProtocol) return;

    final zapData = ZapSocketData.fromJsonString(event);

    if( zapData.event == "zap+nat-v1::aqua_indigo::" ){
      _idConnection = zapData.zapId;
      socketState = SocketState.online;
      if(_onConnectedCallback != null) _onConnectedCallback!();
      return;
    }

    EventManager.dispatchEvents(zapData, socketEvents);
    _anySocketEvent?.callback( zapData.event ,zapData.payload);

    _anyEventStream.add(SocketData(zapData.event , zapData.payload));
  
  }
  //***************************************


  void _onTerminated() {

    if (_isAboutDisconnectedCallback != null && _webSocketChannel != null){
      _isAboutDisconnectedCallback!();
      _isAboutDisconnectedCallback = null;
    }

    _webSocketChannel?.sink.close();

  }

  void _onClosedSocket(){

    if(_onDisconnectedCallback != null ){
      _onDisconnectedCallback!();
    }

    if ( socketState == SocketState.online ){
      socketState  = SocketState.offline;
      Timer(Duration(seconds: 1), () => tryConnection(_uri));
    }

  }

  void _onConnectionFail( err )async{

    print("Retrying Connection with the server...");
    print( err );
    Timer( Duration(seconds: 5), () => tryConnection(_uri) );

  }
}

