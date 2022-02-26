ZapTools is wrapper to WebSocket protocol. 

## Getting started

zap_client is a package to able to connect with servers that can use a Zaptools Adapters (like FastApi).

## Usage



```dart
  final Uri uri = Uri.parse("ws://localhost:8000/");

  final ZapSocketClient ws = ZapSocketClient.connectTo(uri: uri);

  ws.onConnected(() => ws.send('myEvent', "This a message"));

  ws.onEvent("eventFromServer", (payload) => print(payload));

  ws.onAnyEvent((event, payload) => print([event , payload]));

  ws.onDisconnected(() => print("Disconnected"));
```

Create a instance with the constructor, we need a URI, this create a Singleton.
```dart
final Uri uri = Uri.parse("ws://localhost:8000/");

final ZapSocketClient ws = ZapSocketClient.connectTo(uri: uri);
```

you can trigger a callback when is connected to the server

```dart
  ws.onConnected(() => ws.send('myEvent', "This a message"));
```
or when already disconnected to the server
```dart
  ws.onDisconnected(() => print("Disconnected"));
```
>the ZapSocketClient can send a event with payload to the server.

You can register a event and trigger a callback when you receive it.
```dart
  ws.onEvent("eventFromServer", (payload) => print(payload));
```
Also, you have a stream to listen all event
```dart
ws.anyEventStream.listen((data) {
    print(data.event);
    print(data.payload)
  });
```

>payload is data from server



## Additional information

Zaptools is a open-source project that aims to create a layer to make communication easier through websocket.
All PullRequest and bugs report are welcome.
