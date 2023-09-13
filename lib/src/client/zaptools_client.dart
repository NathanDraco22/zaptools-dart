import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketServices {

  void connect(Uri uri){
    final channel = WebSocketChannel.connect(uri);

    channel.stream.listen((event) {
      print(event);
    });
  }

}


class ZapClient{}