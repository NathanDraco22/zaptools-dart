ZapTools is wrapper to handle websocket connection, based on events to a nice and smooth integration .

## Getting started

zap_client is a package to able to connect with servers that can use a Zaptools Adapters (Python/FastApi for now).

## Usage

```dart
import 'package:zap_client/zap_client.dart';

void main() {

  //Connect to localhost websocket server.
  final Uri uri = Uri.parse("ws://localhost:8000/");
  final ZapSocketClient ws = ZapSocketClient.connectTo(uri);

  //trigger when connected
  ws.onConnected(() => ws.send('myEvent', "This a message"));
  //trigger when disconnected
  ws.onDisconnected(() => print("Disconnected"));

  //listening when receive "eventFromServer"
  ws.onEventStream("eventFromServer", (payload) { 
    //do something
    print(payload);
  });

}

```

Create a instance with the constructor, we need a URI, this create a Singleton.
```dart
  //Connect to localhost websocket server.
  final Uri uri = Uri.parse("ws://localhost:8000/");
  final ZapSocketClient ws = ZapSocketClient.connectTo(uri);
```

you can trigger a callback when is connected to the server
```dart
  ws.onConnected(() => ws.send('myEvent', "This a message"));
```
or when already disconnected to the server
```dart
  ws.onDisconnected(() => print("Disconnected"));
```
You can listen a event and trigger a callback when you receive it.
```dart
  //listening when receive "eventFromServer"
  ws.onEventStream("eventFromServer", (payload) { 
    //do something
    print(payload);
  });

```
Also, you have a stream to listen all event
```dart
  ws.anyEventStream.listen((data) {
    //listening all events
    print(data.event); //get event name
    print(data.payload); //get payload
  });
```
To send event and data to the server
```dart
    //Send a event to server
  ws.send("eventToServer", "DATA");

```
>To send a JSON need to parse before.


## Additional information

Zaptools is a open-source project that aims to create a layer to make communication easier through websocket.
All PullRequest and bugs report are welcome.
