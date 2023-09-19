import "package:web_socket_channel/web_socket_channel.dart";
import 'zapclient.dart';
import '../shared/event_tools.dart';
import 'websocket_session.dart';

class ClientConnector {

  static ZapClient connect(Uri uri,{
    Iterable<String>? protocols,
    EventBook? eventBook,
  }){
    final channel = WebSocketChannel.connect(uri, protocols: protocols);
    final session = ChannelSession(channel, uri);
    return ZapClient(
      session,
      eventBook: eventBook ?? EventBook()
    );
  }

  static void tryReconnect(ZapClient client) async{
    await client.disconnect();
    final uri = client.uri;
    final channel = WebSocketChannel.connect(uri);
    final session = ChannelSession(channel, uri);
    client.updateSession(session);
    client.start();
  }

}