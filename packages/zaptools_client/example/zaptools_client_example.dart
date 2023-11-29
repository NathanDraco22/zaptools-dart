
void main() {

  Uri uri = Uri.parse('ws://127.0.0.1:8000/');
  final zapClient = ClientConnector.connect(uri);

  zapClient.onConnected((eventData) {
    print('connected!');
   });

  zapClient.onDisconnected((eventData) {
    print('disconnected!');
  });

  zapClient.sendEvent('hello', 'hello from client');

  zapClient.onEvent('bye', (eventData) async {
    print(eventData.name);
    print(eventData.payload);
    await Future.delayed(Duration(seconds: 1));
    zapClient.disconnect;
  },);


}
