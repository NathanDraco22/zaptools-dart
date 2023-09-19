import 'dart:io';

import 'package:zaptools/src/shared/event_tools.dart';

class ServerConnector {

  plugAndStartIO( HttpRequest req, EventRegister register ) async {
     
     final ws = await WebSocketTransformer.upgrade(req);
  
     ws.listen((event) { });

  
  }




}


