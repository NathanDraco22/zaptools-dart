import 'package:zaptools_server/zaptools_server.dart';

void main() async {
  final app = ZapServer();

  app.onConnected((contexts) {
    print('client connected');
  });

  app.onDisconnected((context) {
    print('client disconnected!');
  });

  app.onEvent('hello', (context) {
    context.connection.send('bye', 'see ya!');
  });

  final server = await app.start();
  print('listen on -> ${server.port}');
}
