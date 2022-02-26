import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/zap_data_model.dart';
import 'sockets_class/event_manager.dart';
import 'sockets_class/socket_interface.dart';

enum SocketState{
  online,
  offline,
}

class ZapSocketClient implements WebSocketInterface{

//----------------------PROPERTIES----------------------------------------------

  SocketState _socketState = SocketState.offline;

  SocketState get socketState => _socketState;

  final StreamController<SocketData> _anyEventStream = StreamController.broadcast();

  Stream<SocketData> get anyEventStream => _anyEventStream.stream;

  void disposeStreamSocketData(){
    _anyEventStream.close();
  }

  late Uri _uri;
  
  WebSocketChannel? _webSocketChannel;

  String? _idConnection;
  
  Function? _onConnectedCallback;
  Function? _onDisconnectedCallback;
  Function? _isAboutDisconnectedCallback;

  // SINGLETON
  static final ZapSocketClient _webSocketClient = ZapSocketClient._private();

  String? get idConnection => _idConnection;

  @override
  String? get protocol {
    return _webSocketChannel?.protocol;
  }

//-------------------- CONSTRUCTOR----------------------------------------------

  ZapSocketClient._private();

  ZapSocketClient.newInstance(this._uri){
    tryConnection(_uri);
  }
  
  factory ZapSocketClient.connectTo(Uri uri){

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
    if (_socketState == SocketState.online) return;

    _webSocketChannel = WebSocketChannel.connect(uri);

    _webSocketChannel?.stream.listen(_eventController,
      cancelOnError: true,
      onDone:  _onClosedSocket,
      onError: _onConnectionFail 
    );
  }
  //********************** */

  @override
  void disconnect(){
    _onTerminated();
    _socketState = SocketState.offline;
  }

  @override
  void onConnected( void Function() callback){
    _onConnectedCallback = callback;
  }

  @override
  StreamSubscription<SocketData> onEventStream(String eventName, void Function(dynamic payload) callback){
    final sub = anyEventStream.listen((data) {
      if ( data.event != eventName ) return;
      callback(data.payload);
    });

    return sub ;
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

//------------------------------------------------------------------------------
  //*************************************
  void _eventController( dynamic event ){

    final isPassProtocol = EventManager.checkZapProtocol(event, _webSocketChannel!);

    if (!isPassProtocol) return;

    final zapData = ZapSocketData.fromJsonString(event);

    if( zapData.event == "zap+nat-v1::aqua_indigo::" ){
      _idConnection = zapData.zapId;
      _socketState = SocketState.online;
      if(_onConnectedCallback != null) _onConnectedCallback!();
      return;
    }

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
    if ( _socketState == SocketState.online ){
      _socketState  = SocketState.offline;
      Timer(Duration(seconds: 1), () => tryConnection(_uri));
    }
  }

  void _onConnectionFail( err )async{
    print("Retrying Connection with the server...");
    print( err );
    Timer( Duration(seconds: 4), () => tryConnection(_uri) );
  }
}

